extends ZoneElement
class_name ExitElement
## Une sortie vers une autre zone

# =============================================================================
# GÉOMÉTRIE
# =============================================================================

## Taille de la zone de collision (pour détecter le joueur)
@export var size: Vector2 = Vector2(64, 64)

# =============================================================================
# DESTINATION
# =============================================================================

## ID de la zone cible (ex: "floor1_zone_002")
@export var target_zone_id: String = ""

## Nom du point de spawn dans la zone cible (ex: "entrance_south")
@export var target_spawn_name: String = "default"

# =============================================================================
# TYPE & APPARENCE
# =============================================================================

## Type de sortie
@export_enum("portal", "door", "stairs", "teleporter", "hidden_passage")
var exit_type: String = "portal"

## Couleur de l'effet visuel (pour portails, téléporteurs)
@export var color: Color = Color(0.2, 0.6, 1.0, 0.7)

# =============================================================================
# CONDITIONS (simple pour commencer)
# =============================================================================

## La sortie est-elle verrouillée ?
@export var locked: bool = false

## ID de l'item clé requis pour ouvrir (si verrouillé)
@export var required_key_id: String = ""

## Niveau minimum pour utiliser cette sortie
@export var min_level: int = 0

# =============================================================================
# INITIALISATION
# =============================================================================

func _init():
	element_type = "exit"

# =============================================================================
# MÉTHODES
# =============================================================================

func to_dict() -> Dictionary:
	var dict = super.to_dict()
	
	dict["size"] = [size.x, size.y]
	dict["target_zone_id"] = target_zone_id
	dict["target_spawn_name"] = target_spawn_name
	dict["exit_type"] = exit_type
	dict["color"] = color.to_html()
	dict["locked"] = locked
	dict["required_key_id"] = required_key_id
	dict["min_level"] = min_level
	
	return dict

static func from_dict(data: Dictionary) -> ExitElement:
	var exit = ExitElement.new()
	
	# Propriétés de base
	exit.element_type = data.get("element_type", "exit")
	exit.id = data.get("id", "")
	var pos = data.get("position", [0, 0])
	exit.position = Vector2(pos[0], pos[1])
	
	# Propriétés spécifiques
	var sz = data.get("size", [64, 64])
	exit.size = Vector2(sz[0], sz[1])
	
	exit.target_zone_id = data.get("target_zone_id", "")
	exit.target_spawn_name = data.get("target_spawn_name", "default")
	exit.exit_type = data.get("exit_type", "portal")
	exit.color = Color.from_string(data.get("color", "#3399ffb3"), Color.BLUE)
	exit.locked = data.get("locked", false)
	exit.required_key_id = data.get("required_key_id", "")
	exit.min_level = data.get("min_level", 0)
	
	return exit
