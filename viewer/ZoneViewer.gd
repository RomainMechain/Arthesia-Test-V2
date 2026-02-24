extends Node2D
## Visualiseur de zone - Affiche graphiquement une zone chargée depuis JSON

# =============================================================================
# CONFIGURATION
# =============================================================================

## Chemin du fichier JSON à charger
@export_file("*.json") var zone_json_path: String = "res://test/test_zone.json"

## Zoom de la caméra (plus petit = plus zoomé)
@export var camera_zoom: float = 1.0

# =============================================================================
# RÉFÉRENCES
# =============================================================================

@onready var camera: Camera2D = $Camera2D
@onready var draw_area: Node2D = $DrawArea

# =============================================================================
# DONNÉES
# =============================================================================

var zone: ZoneData = null

# =============================================================================
# GODOT LIFECYCLE
# =============================================================================

func _ready():
	print("=== Zone Viewer ===")
	
	# Configurer la caméra
	camera.zoom = Vector2(camera_zoom, camera_zoom)
	
	# Charger et afficher la zone
	load_and_display_zone()

# =============================================================================
# CHARGEMENT
# =============================================================================

func load_and_display_zone():
	# Charger le JSON
	var file = FileAccess.open(zone_json_path, FileAccess.READ)
	if file == null:
		push_error("Impossible d'ouvrir le fichier : %s" % zone_json_path)
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	# Parser le JSON
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		push_error("Erreur de parsing JSON")
		return
	
	# Créer la ZoneData
	zone = ZoneData.from_dict(json.data)
	
	print("✅ Zone chargée : %s" % zone.name)
	print("   Taille : %s" % zone.size)
	print("   Éléments : %d" % zone.elements.size())
	
	# Centrer la caméra sur la zone
	camera.position = zone.size / 2
	
	# Dessiner
	display_zone()

# =============================================================================
# AFFICHAGE
# =============================================================================

func display_zone():
	# Nettoyer les enfants précédents
	for child in draw_area.get_children():
		child.queue_free()
	
	# Dessiner les éléments
	for element in zone.elements:
		if element is WallElement:
			draw_wall(element)
		elif element is ExitElement:
			draw_exit(element)
	
	# Dessiner les spawn points
	for spawn_name in zone.spawn_points:
		draw_spawn_point(spawn_name, zone.spawn_points[spawn_name])

func draw_wall(wall: WallElement):
	var rect = ColorRect.new()
	rect.position = wall.position
	rect.size = wall.size
	rect.color = wall.color
	draw_area.add_child(rect)
	
	# Ajouter un label avec l'ID
	var label = Label.new()
	label.text = wall.id
	label.position = wall.position + Vector2(5, 5)
	label.add_theme_font_size_override("font_size", 10)
	draw_area.add_child(label)

func draw_exit(exit: ExitElement):
	var rect = ColorRect.new()
	rect.position = exit.position
	rect.size = exit.size
	rect.color = exit.color
	draw_area.add_child(rect)
	
	# Ajouter un label
	var label = Label.new()
	label.text = "EXIT\n→ %s" % exit.target_zone_id
	label.position = exit.position + Vector2(5, 5)
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color.WHITE)
	draw_area.add_child(label)

func draw_spawn_point(spawn_name: String, position: Vector2):
	# Dessiner un cercle pour le spawn
	var marker = Node2D.new()
	marker.position = position
	draw_area.add_child(marker)
	
	# On va dessiner un cercle via _draw
	marker.set_script(preload("res://viewer/SpawnMarker.gd"))
	marker.set("spawn_name", spawn_name)
