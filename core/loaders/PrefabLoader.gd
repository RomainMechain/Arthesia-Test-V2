extends Node
class_name PrefabLoader
## Charge et instancie des prefabs

## Cache des prefabs déjà chargés
static var _prefab_cache: Dictionary = {}

## Chemin de base des prefabs
static var PREFABS_BASE_PATH: String = "res://core/data/prefabs/"

## Charger un prefab depuis son ID
static func load_prefab(prefab_id: String) -> PrefabData:
	# Vérifier le cache
	if _prefab_cache.has(prefab_id):
		return _prefab_cache[prefab_id]
	
	# Chercher le fichier dans les différents dossiers
	var possible_paths = [
		PREFABS_BASE_PATH + "buildings/" + prefab_id + ".json",
		PREFABS_BASE_PATH + "vegetation/" + prefab_id + ".json",
		PREFABS_BASE_PATH + "decoration/" + prefab_id + ".json",
		PREFABS_BASE_PATH + "structures/" + prefab_id + ".json"
	]
	
	for path in possible_paths:
		if FileAccess.file_exists(path):
			var prefab = load_prefab_from_file(path)
			if prefab:
				_prefab_cache[prefab_id] = prefab
				return prefab
	
	push_error("Prefab not found: %s" % prefab_id)
	return null

## Charger un prefab depuis un fichier JSON
static func load_prefab_from_file(filepath: String) -> PrefabData:
	var file = FileAccess.open(filepath, FileAccess.READ)
	if file == null:
		push_error("Cannot open prefab file: %s" % filepath)
		return null
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		push_error("Failed to parse prefab JSON: %s" % filepath)
		return null
	
	return PrefabData.from_dict(json.data)

## Instancier un prefab (retourne un dictionnaire avec éléments + sprite)

static func instantiate_prefab(prefab: PrefabData, position: Vector2) -> Dictionary:
	var result = {
		"elements": [],
		"sprite_node": null
	}

	# DEBUG
	print("🔍 DEBUG instantiate_prefab:")
	print("  - prefab_id: %s" % prefab.prefab_id)
	print("  - visual_config vide? %s" % prefab.visual_config.is_empty())
	print("  - visual_config: %s" % prefab.visual_config)
	
	# Créer le sprite si le prefab a une config visuelle
	if not prefab.visual_config.is_empty() and prefab.visual_config.has("sprite_path"):
		var sprite_path = prefab.visual_config.get("sprite_path", "")
		
		if sprite_path != "" and FileAccess.file_exists(sprite_path):
			print("  🎨 Création du sprite...")
			var sprite = Sprite2D.new()
			sprite.texture = load(sprite_path)
			
			# GARDER centered = true (défaut) et ajuster la position
			sprite.centered = true
			
			# Position au CENTRE du prefab (pas au coin)
			var prefab_size = prefab.size
			sprite.position = position + (prefab_size / 2)

			# Stocker l'ID du prefab dans les métadonnées du sprite
			sprite.set_meta("prefab_id", prefab.prefab_id)
			
			# Appliquer offset si présent
			if prefab.visual_config.has("sprite_offset"):
				var offset = prefab.visual_config.sprite_offset
				if offset is Array and offset.size() == 2:
					sprite.position += Vector2(offset[0], offset[1])
			
			# Appliquer z_index si présent
			if prefab.visual_config.has("z_index"):
				sprite.z_index = prefab.visual_config.z_index
			
			result.sprite_node = sprite
			print("  ✅ Sprite créé (centré sur prefab)")
	
	# Créer les éléments (collisions)
	var instances: Array[ZoneElement] = []
	for element in prefab.elements:
		var element_copy = duplicate_element(element)
		element_copy.position += position
		instances.append(element_copy)
	
	result.elements = instances
	return result

## Dupliquer un élément (pour éviter de modifier l'original)
static func duplicate_element(element: ZoneElement) -> ZoneElement:
	var dict = element.to_dict()
	return ZoneData._create_element_from_dict(dict)

## Charger et instancier une PrefabInstance (VERSION AVEC SPRITE)
static func load_and_instantiate(instance: PrefabInstance) -> Dictionary:
	var prefab = load_prefab(instance.prefab_id)
	if prefab == null:
		return {"elements": [], "sprite_node": null}
	
	return instantiate_prefab(prefab, instance.position)

## Vider le cache (utile pour recharger des prefabs modifiés)
static func clear_cache():
	_prefab_cache.clear()
