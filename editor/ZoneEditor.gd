extends Node2D
## Éditeur visuel de zones Arthesia

# =============================================================================
# NODES
# =============================================================================

@onready var draw_area: Node2D = $DrawArea
@onready var camera: Camera2D = $Camera2D

# UI
@onready var ui_panel: Panel = $UI/Panel
@onready var label_selection: Label = $UI/Panel/VBoxContainer/LabelSelection
@onready var btn_save: Button = $UI/Panel/VBoxContainer/BtnSave
@onready var btn_cancel: Button = $UI/Panel/VBoxContainer/BtnCancel

# =============================================================================
# CONFIGURATION
# =============================================================================

@export_file("*.json") var zone_json_path: String = "res://test/test_environment.json"
@export var camera_zoom: float = 1.0

# =============================================================================
# DONNÉES
# =============================================================================

var zone: ZoneData = null
var zone_file_path: String = ""

# Système de sélection
var selected_element: Node2D = null
var selectable_elements: Array[Node2D] = []

# Système de drag
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

# Modifications
var has_modifications: bool = false
var modified_elements: Array[Node2D] = [] 

# Contrôles caméra
var is_panning: bool = false
var pan_start_pos: Vector2 = Vector2.ZERO

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready():
	print("=== Zone Editor ===")

	# DEBUG : Vérifier que les boutons existent
	print("🔍 btn_save = %s" % btn_save)
	print("🔍 btn_cancel = %s" % btn_cancel)
	
	if btn_save == null:
		push_error("❌ btn_save est null ! Vérifie le chemin dans @onready")
	if btn_cancel == null:
		push_error("❌ btn_cancel est null ! Vérifie le chemin dans @onready")
	
	# Configurer la caméra
	camera.zoom = Vector2(camera_zoom, camera_zoom)
	
	# Connecter les boutons
	btn_save.pressed.connect(_on_save_pressed)
	btn_cancel.pressed.connect(_on_cancel_pressed)
	
	# Vider le cache des prefabs
	PrefabLoader.clear_cache()
	
	# Charger et afficher la zone
	load_and_display_zone()
	
	update_selection_label()

func _input(event):
	"""Gestion des inputs pour la sélection, le drag et la caméra"""
	
	# === ZOOM (Molette) ===
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.zoom *= 1.1
			camera.zoom = camera.zoom.clamp(Vector2(0.3, 0.3), Vector2(3.0, 3.0))
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.zoom *= 0.9
			camera.zoom = camera.zoom.clamp(Vector2(0.3, 0.3), Vector2(3.0, 3.0))
			get_viewport().set_input_as_handled()
			return
	
	# === PAN (Clic droit ou clic molette) ===
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_panning = true
				pan_start_pos = event.position
			else:
				is_panning = false
			get_viewport().set_input_as_handled()
			return
	
	if event is InputEventMouseMotion and is_panning:
		var delta = event.position - pan_start_pos
		camera.position -= delta / camera.zoom.x
		pan_start_pos = event.position
		get_viewport().set_input_as_handled()
		return  # Ne pas traiter le drag en même temps
	
	# === SÉLECTION ET DRAG (Clic gauche) ===
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# Vérifier si le clic est sur l'UI
			var mouse_pos = get_viewport().get_mouse_position()
			if ui_panel and ui_panel.get_global_rect().has_point(mouse_pos):
				# Clic sur l'UI, laisser les boutons gérer
				return
			
			# Début du clic sur le monde
			handle_click(event.position)
			get_viewport().set_input_as_handled()
		else:
			# Fin du clic (relâcher)
			if is_dragging:
				is_dragging = false
				
				# Marquer l'élément comme modifié
				if selected_element and not modified_elements.has(selected_element):
					modified_elements.append(selected_element)
				
				print("📍 Élément déplacé : %s" % get_element_name(selected_element))
				has_modifications = true
				get_viewport().set_input_as_handled()
	
	# === MOUVEMENT PENDANT LE DRAG ===
	if event is InputEventMouseMotion and is_dragging:
		handle_drag(event.position)
		get_viewport().set_input_as_handled()


func _process(delta):
	"""Contrôles caméra au clavier"""
	
	var move_speed = 500.0 / camera.zoom.x
	
	# Déplacement avec flèches
	if Input.is_key_pressed(KEY_UP):
		camera.position.y -= move_speed * delta
	if Input.is_key_pressed(KEY_DOWN):
		camera.position.y += move_speed * delta
	if Input.is_key_pressed(KEY_LEFT):
		camera.position.x -= move_speed * delta
	if Input.is_key_pressed(KEY_RIGHT):
		camera.position.x += move_speed * delta
	
	# Zoom avec Page Up / Page Down
	if Input.is_key_pressed(KEY_PAGEUP):
		camera.zoom *= 1.02
		camera.zoom = camera.zoom.clamp(Vector2(0.3, 0.3), Vector2(3.0, 3.0))
	if Input.is_key_pressed(KEY_PAGEDOWN):
		camera.zoom *= 0.98
		camera.zoom = camera.zoom.clamp(Vector2(0.3, 0.3), Vector2(3.0, 3.0))

# =============================================================================
# CHARGEMENT DE LA ZONE
# =============================================================================

func load_and_display_zone():
	"""Charge et affiche la zone"""
	zone_file_path = zone_json_path
	zone = ZoneLoader.load_zone_from_json(zone_json_path)
	
	if zone:
		display_zone()
	else:
		push_error("Impossible de charger la zone : %s" % zone_json_path)

func display_zone():
	"""Affiche la zone avec tous ses éléments"""
	
	# Nettoyer
	for child in draw_area.get_children():
		child.queue_free()
	
	selectable_elements.clear()
	
	# Dessiner l'environnement
	draw_environment()
	
	# Dessiner les éléments (murs, exits, POIs)
	for element in zone.elements:
		if element is WallElement:
			draw_wall(element)
		elif element is ExitElement:
			draw_exit(element)
		elif element is POIElement:
			var poi_node = draw_poi(element)
			selectable_elements.append(poi_node)  # POIs sélectionnables
	
	# Dessiner les spawn points
	for spawn_name in zone.spawn_points:
		draw_spawn_point(spawn_name, zone.spawn_points[spawn_name])
	
	# Afficher les sprites des prefabs
	if zone.has_meta("sprite_nodes"):
		var sprites = zone.get_meta("sprite_nodes")
		
		# Créer un mapping instance_id → prefab_instance
		var prefabs_map = {}
		for prefab_inst in zone.prefab_instances:
			prefabs_map[prefab_inst.instance_id] = prefab_inst
		
		for sprite in sprites:
			draw_area.add_child(sprite)
			selectable_elements.append(sprite)
			
			# Associer par instance_id
			var instance_id = sprite.get_meta("instance_id", "")
			if prefabs_map.has(instance_id):
				sprite.set_meta("prefab_instance", prefabs_map[instance_id])
				sprite.set_meta("element_type", "prefab")
				print("🎨 Sprite %s associé à %s" % [instance_id, prefabs_map[instance_id].prefab_id])
			else:
				push_warning("⚠️ Sprite sans instance_id valide")

# =============================================================================
# DESSIN (Copié de ZoneViewer)
# =============================================================================

func draw_environment():
	"""Dessine le fond et le décor"""
	if zone.environment == null:
		var bg = ColorRect.new()
		bg.color = Color(0.3, 0.3, 0.3)
		bg.size = zone.size
		bg.z_index = -100
		draw_area.add_child(bg)
		return
	
	var background = ColorRect.new()
	background.color = zone.environment.ground_color
	background.size = zone.size
	background.z_index = -100
	draw_area.add_child(background)
	
	for decor in zone.environment.decor_zones:
		draw_decor_zone(decor)

func draw_decor_zone(decor: Dictionary):
	"""Dessine une zone de décor"""
	var type = decor.get("type", "")
	var shape = decor.get("shape", "rect")
	
	var colors = {
		"dirt_path": Color(0.55, 0.4, 0.25),
		"dirt": Color(0.55, 0.4, 0.25),
		"stone_path": Color(0.7, 0.7, 0.7),
		"water": Color(0.2, 0.4, 0.8),
		"sand": Color(0.9, 0.8, 0.6),
		"snow": Color(0.95, 0.95, 1.0),
		"lava": Color(0.9, 0.3, 0.1),
		"grass_dark": Color(0.3, 0.5, 0.2),
	}
	
	var color = colors.get(type, Color(0.5, 0.5, 0.5))
	
	match shape:
		"rect":
			draw_decor_rect(decor, color)
		"circle":
			draw_decor_circle(decor, color)

func draw_decor_rect(decor: Dictionary, color: Color):
	var pos = decor.get("position", [0, 0])
	var sz = decor.get("size", [100, 100])
	
	var rect = ColorRect.new()
	rect.color = color
	rect.position = Vector2(pos[0], pos[1])
	rect.size = Vector2(sz[0], sz[1])
	rect.z_index = -40
	draw_area.add_child(rect)

func draw_decor_circle(decor: Dictionary, color: Color):
	var center = decor.get("center", [0, 0])
	var radius = decor.get("radius", 50)
	
	var circle = Polygon2D.new()
	circle.color = color
	circle.z_index = -40
	
	var points = PackedVector2Array()
	var segments = 32
	for i in range(segments):
		var angle = (i / float(segments)) * TAU
		var x = cos(angle) * radius
		var y = sin(angle) * radius
		points.append(Vector2(x, y))
	
	circle.polygon = points
	circle.position = Vector2(center[0], center[1])
	draw_area.add_child(circle)

func draw_wall(wall: WallElement):
	"""Dessine un mur avec collision"""
	var wall_body = StaticBody2D.new()
	wall_body.position = wall.position
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = wall.size
	collision.shape = shape
	collision.position = wall.size / 2
	
	var visual = ColorRect.new()
	visual.color = wall.color
	visual.size = wall.size
	
	var label = Label.new()
	label.text = wall.id
	label.position = Vector2(5, 5)
	
	wall_body.add_child(collision)
	wall_body.add_child(visual)
	wall_body.add_child(label)
	
	draw_area.add_child(wall_body)

func draw_exit(exit: ExitElement):
	"""Dessine une sortie"""
	var exit_area = Area2D.new()
	exit_area.position = exit.position
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = exit.size
	collision.shape = shape
	collision.position = exit.size / 2
	
	var visual = ColorRect.new()
	visual.color = exit.color
	visual.size = exit.size
	
	var label = Label.new()
	label.text = "EXIT\n→ " + exit.target_zone_id
	label.position = Vector2(5, 5)
	
	exit_area.add_child(collision)
	exit_area.add_child(visual)
	exit_area.add_child(label)
	
	draw_area.add_child(exit_area)

func draw_poi(poi: POIElement) -> Node2D:
	"""Dessine un POI (sélectionnable)"""
	var poi_node = Node2D.new()
	poi_node.position = poi.position
	
	# Stocker les données du POI
	poi_node.set_meta("poi_data", poi)
	poi_node.set_meta("element_type", "poi")
	
	var colors = {
		"npc": Color(0.2, 0.8, 0.2),
		"chest": Color(0.9, 0.7, 0.2),
		"lore_stone": Color(0.5, 0.5, 0.9),
		"mob_spawner": Color(0.9, 0.2, 0.2)
	}
	
	var color = colors.get(poi.poi_type, Color(1, 0, 1))
	
	var rect = ColorRect.new()
	rect.color = color
	rect.size = Vector2(30, 30)
	rect.position = Vector2(-15, -15)
	
	var label = Label.new()
	label.text = poi.poi_name if poi.poi_name else poi.poi_type
	label.position = Vector2(-50, -30)
	
	poi_node.add_child(rect)
	poi_node.add_child(label)
	
	draw_area.add_child(poi_node)
	return poi_node

func draw_spawn_point(name: String, position: Vector2):
	"""Dessine un point de spawn"""
	var spawn = Node2D.new()
	spawn.position = position
	
	var circle = Polygon2D.new()
	circle.color = Color(0, 1, 0)
	
	var points = PackedVector2Array()
	for i in range(16):
		var angle = (i / 16.0) * TAU
		points.append(Vector2(cos(angle) * 20, sin(angle) * 20))
	circle.polygon = points
	
	var label = Label.new()
	label.text = name
	label.position = Vector2(-30, 25)
	
	spawn.add_child(circle)
	spawn.add_child(label)
	
	draw_area.add_child(spawn)

# =============================================================================
# SÉLECTION ET DRAG
# =============================================================================

func handle_click(screen_pos: Vector2):
	"""Gère le clic sur un élément"""
	
	# Convertir position écran en position monde
	var world_pos = camera.get_global_mouse_position()
	
	# Chercher l'élément cliqué
	var clicked = find_element_at(world_pos)
	
	if clicked:
		selected_element = clicked
		is_dragging = true
		drag_offset = clicked.position - world_pos
		
		print("✅ Sélectionné : %s" % get_element_name(clicked))
		update_selection_label()
	else:
		# Désélectionner
		selected_element = null
		is_dragging = false
		update_selection_label()

func handle_drag(screen_pos: Vector2):
	"""Gère le déplacement d'un élément"""
	if selected_element:
		var world_pos = camera.get_global_mouse_position()
		selected_element.position = world_pos + drag_offset

func find_element_at(pos: Vector2) -> Node2D:
	"""Trouve l'élément à une position donnée"""
	
	# Chercher dans les éléments sélectionnables
	for element in selectable_elements:
		if is_point_in_element(pos, element):
			return element
	
	return null

func is_point_in_element(pos: Vector2, element: Node2D) -> bool:
	"""Vérifie si un point est dans un élément"""
	
	# Pour les POIs (30x30 centré)
	if element.has_meta("element_type") and element.get_meta("element_type") == "poi":
		var rect = Rect2(element.position - Vector2(15, 15), Vector2(30, 30))
		return rect.has_point(pos)
	
	# Pour les sprites (utiliser la texture)
	if element is Sprite2D:
		var sprite: Sprite2D = element
		if sprite.texture:
			var size = sprite.texture.get_size() * sprite.scale
			var top_left = sprite.position
			if sprite.centered:
				top_left -= size / 2
			var rect = Rect2(top_left, size)
			return rect.has_point(pos)
	
	return false

func get_element_name(element: Node2D) -> String:
	"""Retourne le nom d'un élément"""
	if element.has_meta("poi_data"):
		var poi: POIElement = element.get_meta("poi_data")
		return "%s (%s)" % [poi.poi_name if poi.poi_name else poi.id, poi.poi_type]
	elif element is Sprite2D:
		return "Prefab Sprite"
	else:
		return "Élément"

func update_selection_label():
	"""Met à jour le label de sélection"""
	if selected_element:
		label_selection.text = "Sélectionné:\n%s\nPos: %s" % [
			get_element_name(selected_element),
			selected_element.position
		]
	else:
		label_selection.text = "Aucune sélection\nCliquez sur un élément"

# =============================================================================
# SAUVEGARDE
# =============================================================================

func _on_save_pressed():
	"""Sauvegarde les modifications dans le JSON"""
	
	print("\n💾 SAUVEGARDE DE LA ZONE")
	print("==============================")
	
	if not has_modifications or modified_elements.size() == 0:
		print("ℹ️  Aucune modification à sauvegarder")
		print("==============================")
		return
	
	print("📝 Éléments modifiés : %d" % modified_elements.size())
	
	# Charger le JSON original
	var file_read = FileAccess.open(zone_file_path, FileAccess.READ)
	if not file_read:
		push_error("❌ Impossible de lire le fichier : %s" % zone_file_path)
		return
	
	var json_text = file_read.get_as_text()
	file_read.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		push_error("❌ Erreur de parsing JSON")
		return
	
	var zone_data: Dictionary = json.data
	
	# Mettre à jour UNIQUEMENT les éléments modifiés
	for element_node in modified_elements:
		if element_node.has_meta("element_type"):
			var elem_type = element_node.get_meta("element_type")
			
			# POIs
			if elem_type == "poi" and element_node.has_meta("poi_data"):
				var poi: POIElement = element_node.get_meta("poi_data")
				var poi_id = poi.id
				
				# Trouver le POI dans le JSON
				for i in range(zone_data["elements"].size()):
					var elem = zone_data["elements"][i]
					if elem.get("id") == poi_id and elem.get("element_type") == "poi":
						elem["position"] = [element_node.position.x, element_node.position.y]
						print("  ✅ POI mis à jour : %s → (%.0f, %.0f)" % [poi.poi_name, element_node.position.x, element_node.position.y])
						break
			
			# Prefabs
			elif elem_type == "prefab" and element_node.has_meta("prefab_instance"):
				var prefab_inst: PrefabInstance = element_node.get_meta("prefab_instance")
				var instance_id = prefab_inst.instance_id
				
				# Trouver le prefab dans le JSON
				for i in range(zone_data["prefab_instances"].size()):
					var inst = zone_data["prefab_instances"][i]
					if inst.get("instance_id") == instance_id:
						inst["position"] = [element_node.position.x, element_node.position.y]
						print("  ✅ Prefab mis à jour : %s → (%.0f, %.0f)" % [prefab_inst.prefab_id, element_node.position.x, element_node.position.y])
						break
	
	# Sauvegarder
	var file_write = FileAccess.open(zone_file_path, FileAccess.WRITE)
	if file_write:
		var json_output = JSON.stringify(zone_data, "  ")
		file_write.store_string(json_output)
		file_write.close()
		
		print("\n💾 ✅ Zone sauvegardée : %s" % zone_file_path)
		print("==============================")
		
		has_modifications = false
		modified_elements.clear()  # Vider la liste
	else:
		push_error("❌ Impossible d'ouvrir le fichier pour écriture : %s" % zone_file_path)
		print("==============================")

func _on_cancel_pressed():
	"""Annule et recharge la zone"""
	print("🔄 Annulation des modifications...")
	load_and_display_zone()
	has_modifications = false
	modified_elements.clear()
	selected_element = null
	update_selection_label()
