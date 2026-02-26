extends POIElement
class_name ChestElement
## Un coffre contenant des items et de l'or

# =============================================================================
# PROPRIÉTÉS SPÉCIFIQUES AUX COFFRES
# =============================================================================

## Liste des IDs d'items contenus (ex: ["sword_iron", "potion_health"])
@export var contained_items: PackedStringArray = PackedStringArray()

## Quantités correspondantes (ex: [1, 3] = 1 épée, 3 potions)
@export var item_quantities: PackedInt32Array = PackedInt32Array()

## Or contenu
@export var gold: int = 0

## Le coffre peut-il être ouvert plusieurs fois ?
@export var respawnable: bool = false

## Si respawnable, temps de respawn en secondes
@export var respawn_time: float = 300.0

## Le coffre a-t-il déjà été ouvert ? (état persistant)
@export var opened: bool = false

# =============================================================================
# INITIALISATION
# =============================================================================

func _init():
	element_type = "poi"
	poi_type = "chest"
	interaction_text = "Ouvrir"

# =============================================================================
# MÉTHODES
# =============================================================================

func to_dict() -> Dictionary:
	var dict = super.to_dict()
	
	dict["contained_items"] = Array(contained_items)
	dict["item_quantities"] = Array(item_quantities)
	dict["gold"] = gold
	dict["respawnable"] = respawnable
	dict["respawn_time"] = respawn_time
	dict["opened"] = opened
	
	return dict

static func from_dict(data: Dictionary) -> ChestElement:
	var chest = ChestElement.new()
	
	# Propriétés de base POI
	chest.element_type = data.get("element_type", "poi")
	chest.id = data.get("id", "")
	
	var pos = data.get("position", [0, 0])
	chest.position = Vector2(pos[0], pos[1])
	
	chest.poi_name = data.get("poi_name", "Coffre")
	chest.poi_type = data.get("poi_type", "chest")
	chest.sprite_path = data.get("sprite_path", "")
	chest.interactable = data.get("interactable", true)
	chest.interaction_text = data.get("interaction_text", "Ouvrir")
	chest.has_conditions = data.get("has_conditions", false)
	
	# Propriétés spécifiques coffre
	chest.contained_items = PackedStringArray(data.get("contained_items", []))
	chest.item_quantities = PackedInt32Array(data.get("item_quantities", []))
	chest.gold = data.get("gold", 0)
	chest.respawnable = data.get("respawnable", false)
	chest.respawn_time = data.get("respawn_time", 300.0)
	chest.opened = data.get("opened", false)
	
	return chest
