extends Node

func _ready():
	print("=== Test de chargement d'une zone complète ===\n")
	
	# Charger le fichier JSON
	var file = FileAccess.open("res://test/test_zone.json", FileAccess.READ)
	if file == null:
		print("❌ Impossible d'ouvrir le fichier JSON")
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	# Parser le JSON
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		print("❌ Erreur de parsing JSON")
		return
	
	var data = json.data
	
	# Créer la ZoneData depuis le JSON
	var zone = ZoneData.from_dict(data)
	
	# Afficher les infos
	print("✅ Zone chargée avec succès !")
	print("\nID: ", zone.id)
	print("Nom: ", zone.name)
	print("Étage: ", zone.floor_id)
	print("Description: ", zone.description)
	print("Taille: ", zone.size)
	print("Niveau: %d-%d" % [zone.level_range.x, zone.level_range.y])
	
	print("\nSpawn points:")
	for spawn_name in zone.spawn_points:
		print("  - %s: %s" % [spawn_name, zone.spawn_points[spawn_name]])
	
	print("\nNombre d'éléments: ", zone.elements.size())
	
	# Lister les éléments
	print("\n--- ÉLÉMENTS ---")
	for element in zone.elements:
		print("  - %s (%s) à position %s" % [element.id, element.element_type, element.position])
		
		# Info spécifique selon le type
		if element is WallElement:
			print("    Taille: %s, Type: %s" % [element.size, element.wall_type])
		elif element is ExitElement:
			print("    Destination: %s → spawn '%s'" % [element.target_zone_id, element.target_spawn_name])
			print("    Verrouillé: %s" % element.locked)
	
	# Test de sauvegarde (JSON → objet → JSON)
	print("\n--- TEST ROUND-TRIP (JSON → Objet → JSON) ---")
	var new_dict = zone.to_dict()
	print(JSON.stringify(new_dict, "  "))
	
	# Test de la fonction helper get_spawn_point()
	print("\n--- TEST get_spawn_point() ---")
	print("Spawn 'entrance_north': ", zone.get_spawn_point("entrance_north"))
	print("Spawn 'entrance_south': ", zone.get_spawn_point("entrance_south"))
	print("Spawn 'inexistant' (fallback): ", zone.get_spawn_point("inexistant"))
