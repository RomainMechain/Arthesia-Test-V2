extends Resource
class_name PrefabData
## Définition d'un prefab (modèle réutilisable)

# =============================================================================
# IDENTITÉ
# =============================================================================

## ID unique du prefab (ex: "house_simple", "tree_oak")
@export var prefab_id: String = ""

## Type de prefab (building, vegetation, decoration, structure)
@export_enum("building", "vegetation", "decoration", "structure", "other")
var prefab_type: String = "other"

## Nom du prefab
@export var name: String = ""

# =============================================================================
# DIMENSIONS
# =============================================================================

## Taille approximative du prefab (pour placement)
@export var size: Vector2 = Vector2.ZERO

## Point d'ancrage (0,0 = coin supérieur gauche)
@export var anchor_point: Vector2 = Vector2.ZERO

# =============================================================================
# ÉLÉMENTS
# =============================================================================

## Tous les éléments qui composent ce prefab
@export var elements: Array[ZoneElement] = []

# =============================================================================
# MÉTHODES
# =============================================================================

func to_dict() -> Dictionary:
	return {
		"prefab_id": prefab_id,
		"prefab_type": prefab_type,
		"name": name,
		"size": [size.x, size.y],
		"anchor_point": [anchor_point.x, anchor_point.y],
		"elements": elements.map(func(e): return e.to_dict())
	}

static func from_dict(data: Dictionary) -> PrefabData:
	var prefab = PrefabData.new()
	
	prefab.prefab_id = data.get("prefab_id", "")
	prefab.prefab_type = data.get("prefab_type", "other")
	prefab.name = data.get("name", "")
	
	var sz = data.get("size", [0, 0])
	prefab.size = Vector2(sz[0], sz[1])
	
	var ap = data.get("anchor_point", [0, 0])
	prefab.anchor_point = Vector2(ap[0], ap[1])
	
	# Charger les éléments
	for element_data in data.get("elements", []):
		var element = ZoneData._create_element_from_dict(element_data)
		if element:
			prefab.elements.append(element)
	
	return prefab
