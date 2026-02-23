extends ZoneElement
class_name WallElement
## Un mur ou obstacle dans une zone

# =============================================================================
# PROPRIÉTÉS SPÉCIFIQUES AUX MURS
# =============================================================================

## Taille du mur (largeur, hauteur)
@export var size: Vector2 = Vector2(64, 64)

## Type de mur
@export_enum("stone", "wood", "rock", "tree", "cliff") 
var wall_type: String = "stone"

## Couleur (temporaire, pour le debug)
@export var color: Color = Color(0.5, 0.5, 0.5)

# =============================================================================
# INITIALISATION
# =============================================================================

func _init():
	# Définir le type de cet élément
	element_type = "wall"

# =============================================================================
# MÉTHODES (Override des méthodes de base)
# =============================================================================

## Convertir en dictionnaire
func to_dict() -> Dictionary:
	# Récupérer le dict de base (element_type, id, position)
	var dict = super.to_dict()
	
	# Ajouter nos propriétés spécifiques
	dict["size"] = [size.x, size.y]
	dict["wall_type"] = wall_type
	dict["color"] = color.to_html()
	
	return dict

## Créer depuis un dictionnaire
static func from_dict(data: Dictionary) -> WallElement:
	var wall = WallElement.new()
	
	# Propriétés de base
	wall.element_type = data.get("element_type", "wall")
	wall.id = data.get("id", "")
	
	var pos = data.get("position", [0, 0])
	wall.position = Vector2(pos[0], pos[1])
	
	# Propriétés spécifiques
	var sz = data.get("size", [64, 64])
	wall.size = Vector2(sz[0], sz[1])
	
	wall.wall_type = data.get("wall_type", "stone")
	wall.color = Color.from_string(data.get("color", "#808080"), Color.GRAY)
	
	return wall
