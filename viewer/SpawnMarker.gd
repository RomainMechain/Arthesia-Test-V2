extends Node2D
## Marker visuel pour un spawn point

var spawn_name: String = "default"

func _draw():
	# Dessiner un cercle vert
	draw_circle(Vector2.ZERO, 10, Color(0, 1, 0, 0.8))
	draw_arc(Vector2.ZERO, 10, 0, TAU, 32, Color(0, 0.6, 0), 2)

func _ready():
	# Ajouter un label
	var label = Label.new()
	label.text = spawn_name
	label.position = Vector2(-30, 15)
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color.GREEN)
	add_child(label)
