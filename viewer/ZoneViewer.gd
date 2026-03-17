extends Node2D
## Visualiseur de zone - Affiche graphiquement une zone chargée depuis JSON

# =============================================================================
# CONFIGURATION
# =============================================================================

## Chemin du fichier JSON à charger
@export_file("*.json") var zone_json_path: String = "res://test/village_002.json"

## Zoom de la caméra (plus petit = plus zoomé)
@export var camera_zoom: float = 0.5

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
	spawn_player()

# =============================================================================
# CHARGEMENT
# =============================================================================

func load_and_display_zone():
	# Utiliser ZoneLoader pour charger la zone
	zone = ZoneLoader.load_zone_from_json(zone_json_path)
	
	if zone == null:
		push_error("Failed to load zone from: %s" % zone_json_path)
		return
	
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
		elif element is POIElement:  # ← NOUVEAU
			draw_poi(element)
	
	# Dessiner les spawn points
	for spawn_name in zone.spawn_points:
		draw_spawn_point(spawn_name, zone.spawn_points[spawn_name])

func draw_wall(wall: WallElement):
	# Créer un StaticBody2D pour la collision
	var static_body = StaticBody2D.new()
	static_body.position = wall.position
	draw_area.add_child(static_body)
	
	# Ajouter une CollisionShape2D
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = wall.size
	collision.shape = shape
	collision.position = wall.size / 2  # Centrer la shape
	static_body.add_child(collision)
	
	# Ajouter le visuel (ColorRect) comme enfant du StaticBody
	var rect = ColorRect.new()
	rect.position = Vector2.ZERO  # Position relative au StaticBody
	rect.size = wall.size
	rect.color = wall.color
	static_body.add_child(rect)
	
	# Ajouter un label avec l'ID
	var label = Label.new()
	label.text = wall.id
	label.position = Vector2(5, 5)
	label.add_theme_font_size_override("font_size", 10)
	static_body.add_child(label)

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

@warning_ignore("shadowed_variable_base_class")
func draw_spawn_point(spawn_name: String, position: Vector2):
	# Dessiner un cercle pour le spawn
	var marker = Node2D.new()
	marker.position = position
	draw_area.add_child(marker)
	
	# On va dessiner un cercle via _draw
	marker.set_script(preload("res://viewer/SpawnMarker.gd"))
	marker.set("spawn_name", spawn_name)
	
func draw_poi(poi: POIElement):
	# Couleur selon le type
	var poi_color = Color.WHITE
	if poi is ChestElement:
		poi_color = Color(1.0, 0.84, 0.0)  # Or (coffre)
	elif poi is NPCElement:
		poi_color = Color(0.0, 1.0, 0.5)  # Vert clair (PNJ)
	elif poi is LoreStoneElement:
		poi_color = Color(0.5, 0.7, 1.0)  # Bleu clair (lore)
	
	# Dessiner un carré pour le POI
	var rect = ColorRect.new()
	rect.position = poi.position - Vector2(15, 15)  # Centré
	rect.size = Vector2(30, 30)
	rect.color = poi_color
	draw_area.add_child(rect)
	
	# Ajouter un label
	var label = Label.new()
	label.text = poi.poi_name
	label.position = poi.position + Vector2(-50, 20)
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", poi_color)
	draw_area.add_child(label)
	
	
func spawn_player():
	"""Instancie le joueur dans la zone"""
	
	# Charger la scène Player
	var player_scene = load("res://player/Player.tscn")
	var player = player_scene.instantiate()
	
	# Positionner le joueur au spawn point par défaut
	if zone:
		player.position = zone.get_spawn_point("default")
	else:
		player.position = Vector2(400, 400)  # Position par défaut si pas de zone
	
	# Ajouter le joueur à la scène
	add_child(player)
	
	print("✅ Player spawné à la position : %s" % player.position)
