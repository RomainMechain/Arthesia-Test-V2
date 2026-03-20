extends Resource
class_name ZoneData
## Données complètes d'une zone de jeu

# =============================================================================
# IDENTITÉ
# =============================================================================

## ID unique de la zone (ex: "floor1_zone_001")
@export var id: String = ""

## Nom de la zone (ex: "Le Village de l'Éveil")
@export var name: String = "Unnamed Zone"

## Numéro de l'étage
@export var floor_id: int = 1

## Tags thématiques (ex: ["village", "peaceful", "tutorial"])
@export var theme_tags: PackedStringArray = PackedStringArray()

## Niveau recommandé min-max
@export var level_range: Vector2i = Vector2i(1, 10)

# =============================================================================
# DESCRIPTION
# =============================================================================

## Description de la zone (pour le lore)
@export_multiline var description: String = ""

# =============================================================================
# DIMENSIONS
# =============================================================================

## Taille de la zone en pixels
@export var size: Vector2 = Vector2(1024, 1024)

## Points de spawn nommés (nom → position)
## Ex: {"default": Vector2(400, 300), "entrance_north": Vector2(400, 50)}
@export var spawn_points: Dictionary = {}

# =============================================================================
# PREFABS
# =============================================================================

## Instances de prefabs dans cette zone
@export var prefab_instances: Array[PrefabInstance] = []

# =============================================================================
# ÉLÉMENTS DE LA ZONE
# =============================================================================

## TOUS les éléments de la zone (walls, exits, poi, etc.)
@export var elements: Array[ZoneElement] = []

# =============================================================================
# ENVIRONNEMENT VISUEL
# =============================================================================

## Configuration de l'environnement (sol, décor, etc.)
@export var environment: EnvironmentConfig = null

# =============================================================================
# MÉTHODES
# =============================================================================

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"floor_id": floor_id,
		"theme_tags": Array(theme_tags),
		"level_range": [level_range.x, level_range.y],
		"description": description,
		"size": [size.x, size.y],
		"spawn_points": _spawn_points_to_dict(),
		"environment": environment.to_dict() if environment else {},
		"prefab_instances": prefab_instances.map(func(p): return p.to_dict()),
		"elements": elements.map(func(e): return e.to_dict())
	}

static func from_dict(data: Dictionary) -> ZoneData:
	var zone = ZoneData.new()
	
	zone.id = data.get("id", "")
	zone.name = data.get("name", "Unnamed Zone")
	zone.floor_id = data.get("floor_id", 1)
	zone.theme_tags = PackedStringArray(data.get("theme_tags", []))
	
	var lr = data.get("level_range", [1, 10])
	zone.level_range = Vector2i(lr[0], lr[1])
	
	zone.description = data.get("description", "")
	
	var sz = data.get("size", [1024, 1024])
	zone.size = Vector2(sz[0], sz[1])
	
	# Charger les spawn points
	var spawn_data = data.get("spawn_points", {})
	for spawn_name in spawn_data:
		var pos_array = spawn_data[spawn_name]
		zone.spawn_points[spawn_name] = Vector2(pos_array[0], pos_array[1])

	# Charger l'environnement
	if data.has("environment") and not data.environment.is_empty():
		zone.environment = EnvironmentConfig.from_dict(data.environment)
	
	# Si aucun spawn point défini, créer un "default"
	if zone.spawn_points.is_empty():
		zone.spawn_points["default"] = Vector2(100, 100)
		
	# Charger les prefab instances
	for prefab_data in data.get("prefab_instances", []):
		zone.prefab_instances.append(PrefabInstance.from_dict(prefab_data))
	
	# Charger les éléments
	for element_data in data.get("elements", []):
		var element = _create_element_from_dict(element_data)
		if element:
			zone.elements.append(element)
	
	return zone

## Convertir spawn_points (Dictionary Vector2) en format JSON
func _spawn_points_to_dict() -> Dictionary:
	var result = {}
	for spawn_name in spawn_points:
		var pos: Vector2 = spawn_points[spawn_name]
		result[spawn_name] = [pos.x, pos.y]
	return result

## Créer le bon type d'élément selon element_type
static func _create_element_from_dict(data: Dictionary) -> ZoneElement:
	var element_type = data.get("element_type", "")
	
	match element_type:
		"wall":
			return WallElement.from_dict(data)
		"exit":
			return ExitElement.from_dict(data)
		"poi":
			# Déterminer le sous-type de POI
			var poi_type = data.get("poi_type", "")
			match poi_type:
				"chest":
					return ChestElement.from_dict(data)
				"npc":
					return NPCElement.from_dict(data)
				"lore_stone":
					return LoreStoneElement.from_dict(data)
				_:
					# POI générique
					return POIElement.from_dict(data)
		_:
			# Type inconnu, on crée un ZoneElement de base
			push_warning("Unknown element type: %s" % element_type)
			return ZoneElement.from_dict(data)

## Obtenir un spawn point par nom (avec fallback sur "default")
func get_spawn_point(spawn_name: String) -> Vector2:
	if spawn_points.has(spawn_name):
		return spawn_points[spawn_name]
	elif spawn_points.has("default"):
		return spawn_points["default"]
	else:
		# Aucun spawn point défini, retourner centre de la zone
		return size / 2
