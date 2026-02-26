extends Resource
class_name PrefabInstance
## Instance d'un prefab dans une zone (placement)

# =============================================================================
# RÉFÉRENCE
# =============================================================================

## ID du prefab à instancier (ex: "house_simple")
@export var prefab_id: String = ""

## ID unique de cette instance (ex: "house_001")
@export var instance_id: String = ""

# =============================================================================
# TRANSFORMATION
# =============================================================================

## Position dans la zone
@export var position: Vector2 = Vector2.ZERO

## Rotation en degrés (pour plus tard)
@export var rotation: float = 0.0

## Scale (pour plus tard, si on veut varier les tailles)
@export var scale: float = 1.0

# =============================================================================
# OVERRIDES (pour personnaliser des instances)
# =============================================================================

## Dictionnaire de valeurs à override (pour plus tard)
## Ex: {"elements.door.target_zone_id": "custom_interior"}
@export var overrides: Dictionary = {}

# =============================================================================
# MÉTHODES
# =============================================================================

func to_dict() -> Dictionary:
	return {
		"prefab_id": prefab_id,
		"instance_id": instance_id,
		"position": [position.x, position.y],
		"rotation": rotation,
		"scale": scale,
		"overrides": overrides
	}

static func from_dict(data: Dictionary) -> PrefabInstance:
	var instance = PrefabInstance.new()
	
	instance.prefab_id = data.get("prefab_id", "")
	instance.instance_id = data.get("instance_id", "")
	
	var pos = data.get("position", [0, 0])
	instance.position = Vector2(pos[0], pos[1])
	
	instance.rotation = data.get("rotation", 0.0)
	instance.scale = data.get("scale", 1.0)
	instance.overrides = data.get("overrides", {})
	
	return instance
