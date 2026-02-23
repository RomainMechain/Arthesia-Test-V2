extends Resource
class_name ZoneElement
## Classe de base pour tous les éléments d'une zone

# =============================================================================
# PROPRIÉTÉS COMMUNES À TOUS LES ÉLÉMENTS
# =============================================================================

## Type d'élément (sera défini dans les classes enfants)
@export var element_type: String = ""

## ID unique de l'élément (ex: "wall_001", "exit_north")
@export var id: String = ""

## Position de l'élément dans la zone (en pixels)
@export var position: Vector2 = Vector2.ZERO

# =============================================================================
# MÉTHODES
# =============================================================================

## Convertir en dictionnaire (pour JSON)
func to_dict() -> Dictionary:
	return {
		"element_type": element_type,
		"id": id,
		"position": [position.x, position.y]
	}

## Créer depuis un dictionnaire (depuis JSON)
static func from_dict(data: Dictionary) -> ZoneElement:
	var element = ZoneElement.new()
	element.element_type = data.get("element_type", "")
	element.id = data.get("id", "")
	
	var pos = data.get("position", [0, 0])
	element.position = Vector2(pos[0], pos[1])
	
	return element
