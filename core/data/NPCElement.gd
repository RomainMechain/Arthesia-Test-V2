extends POIElement
class_name NPCElement
## Un personnage non-joueur (PNJ)

# =============================================================================
# PROPRIÉTÉS SPÉCIFIQUES AUX PNJ
# =============================================================================

## Liste de phrases de dialogue
@export var dialogues: Array[String] = []

## ID de la quête donnée par ce PNJ (si applicable)
## Pour l'instant c'est juste un String, on gérera les quêtes plus tard
@export var quest_id: String = ""

## Type de PNJ (marchand, quest_giver, villager, etc.)
@export_enum("villager", "merchant", "quest_giver", "guard", "elder")
var npc_type: String = "villager"

# =============================================================================
# INITIALISATION
# =============================================================================

func _init():
	element_type = "poi"
	poi_type = "npc"
	interaction_text = "Parler"

# =============================================================================
# MÉTHODES
# =============================================================================

func to_dict() -> Dictionary:
	var dict = super.to_dict()
	
	dict["dialogues"] = dialogues
	dict["quest_id"] = quest_id
	dict["npc_type"] = npc_type
	
	return dict

static func from_dict(data: Dictionary) -> NPCElement:
	var npc = NPCElement.new()
	
	# Propriétés de base POI
	npc.element_type = data.get("element_type", "poi")
	npc.id = data.get("id", "")
	
	var pos = data.get("position", [0, 0])
	npc.position = Vector2(pos[0], pos[1])
	
	npc.poi_name = data.get("poi_name", "PNJ")
	npc.poi_type = data.get("poi_type", "npc")
	npc.sprite_path = data.get("sprite_path", "")
	npc.interactable = data.get("interactable", true)
	npc.interaction_text = data.get("interaction_text", "Parler")
	npc.has_conditions = data.get("has_conditions", false)
	
	# Propriétés spécifiques PNJ
	var dialogues_data = data.get("dialogues", [])
	for dialogue in dialogues_data:
		npc.dialogues.append(dialogue)
	npc.quest_id = data.get("quest_id", "")
	npc.npc_type = data.get("npc_type", "villager")
	
	return npc
