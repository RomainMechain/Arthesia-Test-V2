extends ZoneElement
class_name POIElement
## Classe de base pour tous les Points d'Intérêt

# =============================================================================
# PROPRIÉTÉS COMMUNES À TOUS LES POI
# =============================================================================

## Nom affiché du POI (ex: "Coffre Ancien", "Marchand Errant")
@export var poi_name: String = ""

## Sous-type de POI (sera défini dans les classes enfants)
@export var poi_type: String = ""

## Sprite/icône du POI
@export var sprite_path: String = ""

## Le POI est-il interactif ?
@export var interactable: bool = true

## Texte d'interaction (ex: "Ouvrir", "Parler", "Examiner")
@export var interaction_text: String = "Interagir"

## Conditions pour interagir (TODO: à implémenter plus tard)
## Pour l'instant, juste un placeholder
@export var has_conditions: bool = false

# =============================================================================
# INITIALISATION
# =============================================================================

func _init():
	element_type = "poi"

# =============================================================================
# MÉTHODES
# =============================================================================

func to_dict() -> Dictionary:
	var dict = super.to_dict()
	
	dict["poi_name"] = poi_name
	dict["poi_type"] = poi_type
	dict["sprite_path"] = sprite_path
	dict["interactable"] = interactable
	dict["interaction_text"] = interaction_text
	dict["has_conditions"] = has_conditions
	
	return dict

static func from_dict(data: Dictionary) -> POIElement:
	# Cette méthode sera override dans les sous-classes
	# Mais on la définit quand même pour la base
	var poi = POIElement.new()
	
	poi.element_type = data.get("element_type", "poi")
	poi.id = data.get("id", "")
	
	var pos = data.get("position", [0, 0])
	poi.position = Vector2(pos[0], pos[1])
	
	poi.poi_name = data.get("poi_name", "")
	poi.poi_type = data.get("poi_type", "")
	poi.sprite_path = data.get("sprite_path", "")
	poi.interactable = data.get("interactable", true)
	poi.interaction_text = data.get("interaction_text", "Interagir")
	poi.has_conditions = data.get("has_conditions", false)
	
	return poi
