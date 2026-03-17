extends CharacterBody2D
## Script du joueur - Mouvement WASD

# =============================================================================
# CONSTANTES
# =============================================================================

const SPEED = 200.0  # Vitesse de déplacement (pixels/seconde)

# =============================================================================
# MOUVEMENT
# =============================================================================

func _physics_process(delta):
	# Récupérer la direction depuis les inputs (WASD ou flèches)
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Calculer la vélocité
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	
	# Bouger le personnage
	move_and_slide()
