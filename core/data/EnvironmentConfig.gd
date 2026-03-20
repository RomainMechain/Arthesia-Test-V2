extends Resource
class_name EnvironmentConfig
## Configuration de l'environnement visuel d'une zone

# =============================================================================
# TYPE D'ENVIRONNEMENT
# =============================================================================

## Type d'environnement principal
@export_enum("grass", "forest", "stone", "sand", "snow", "cave", "ruins")
var ground_type: String = "grass"

## Couleur du sol de base
@export var ground_color: Color = Color(0.4, 0.6, 0.3)  # Vert herbe par défaut

# =============================================================================
# ZONES DE DÉCOR
# =============================================================================

## Zones de décor spéciales (chemins, eau, etc.)
@export var decor_zones: Array[Dictionary] = []

# =============================================================================
# MÉTHODES
# =============================================================================

func to_dict() -> Dictionary:
	return {
		"ground_type": ground_type,
		"ground_color": ground_color.to_html(),
		"decor_zones": decor_zones
	}

static func from_dict(data: Dictionary) -> EnvironmentConfig:
	var env = EnvironmentConfig.new()
	
	env.ground_type = data.get("ground_type", "grass")
	
	# Parser la couleur
	var color_str = data.get("ground_color", "#5A964A")
	env.ground_color = Color(color_str)
	
	# Charger les zones de décor (avec boucle pour éviter l'erreur de type)
	var decor_data = data.get("decor_zones", [])
	for decor in decor_data:
		env.decor_zones.append(decor)
	
	return env
