extends POIElement
class_name LoreStoneElement
## Une pierre ou monument avec du lore à lire

# =============================================================================
# PROPRIÉTÉS SPÉCIFIQUES AUX PIERRES DE LORE
# =============================================================================

## Texte de lore à afficher (peut être long)
@export_multiline var lore_text: String = ""

## Catégorie du lore (pour organisation)
@export_enum("architects", "fracture", "tower", "guardians", "history", "mystery")
var lore_category: String = "history"

# =============================================================================
# INITIALISATION
# =============================================================================

func _init():
	element_type = "poi"
	poi_type = "lore_stone"
	interaction_text = "Examiner"

# =============================================================================
# MÉTHODES
# =============================================================================

func to_dict() -> Dictionary:
	var dict = super.to_dict()
	
	dict["lore_text"] = lore_text
	dict["lore_category"] = lore_category
	
	return dict

static func from_dict(data: Dictionary) -> LoreStoneElement:
	var stone = LoreStoneElement.new()
	
	# Propriétés de base POI
	stone.element_type = data.get("element_type", "poi")
	stone.id = data.get("id", "")
	
	var pos = data.get("position", [0, 0])
	stone.position = Vector2(pos[0], pos[1])
	
	stone.poi_name = data.get("poi_name", "Pierre Ancienne")
	stone.poi_type = data.get("poi_type", "lore_stone")
	stone.sprite_path = data.get("sprite_path", "")
	stone.interactable = data.get("interactable", true)
	stone.interaction_text = data.get("interaction_text", "Examiner")
	stone.has_conditions = data.get("has_conditions", false)
	
	# Propriétés spécifiques lore stone
	stone.lore_text = data.get("lore_text", "")
	stone.lore_category = data.get("lore_category", "history")
	
	return stone
