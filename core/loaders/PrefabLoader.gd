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

## Instancier un prefab (retourne les éléments avec positions ajustées)
static func instantiate_prefab(prefab: PrefabData, position: Vector2) -> Array[ZoneElement]:
	var instances: Array[ZoneElement] = []
	
	for element in prefab.elements:
		# Créer une copie de l'élément
		var element_copy = duplicate_element(element)
		
		# Ajuster la position
		element_copy.position += position
		
		instances.append(element_copy)
	
	return instances

## Dupliquer un élément (pour éviter de modifier l'original)
static func duplicate_element(element: ZoneElement) -> ZoneElement:
	var dict = element.to_dict()
	return ZoneData._create_element_from_dict(dict)

## Charger et instancier une PrefabInstance
static func load_and_instantiate(instance: PrefabInstance) -> Array[ZoneElement]:
	var prefab = load_prefab(instance.prefab_id)
	if prefab == null:
		return []
	
	return instantiate_prefab(prefab, instance.position)

## Vider le cache (utile pour recharger des prefabs modifiés)
static func clear_cache():
	_prefab_cache.clear()
