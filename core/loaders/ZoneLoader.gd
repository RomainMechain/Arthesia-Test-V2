extends Node
class_name ZoneLoader
## Charge des zones depuis des fichiers JSON et les convertit en ZoneData

## Charge une zone depuis un fichier JSON
static func load_zone_from_json(filepath: String) -> ZoneData:
	if not FileAccess.file_exists(filepath):
		push_error("Zone file not found: %s" % filepath)
		return null
	
	var file = FileAccess.open(filepath, FileAccess.READ)
	if file == null:
		push_error("Failed to open zone file: %s" % filepath)
		return null
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		push_error("Failed to parse JSON: %s at line %d" % [json.get_error_message(), json.get_error_line()])
		return null
	
	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Invalid JSON format: expected dictionary")
		return null
	
	var zone = ZoneData.from_dict(data)
	
	# Charger et instancier les prefabs
	var sprite_nodes = []  # Stocker les sprites à part

	for prefab_instance in zone.prefab_instances:
		var result = PrefabLoader.load_and_instantiate(prefab_instance)
		
		# Ajouter les éléments de collision
		if result.has("elements"):
			zone.elements.append_array(result.elements)
		
		# Stocker le sprite pour l'afficher plus tard
		if result.has("sprite_node") and result.sprite_node != null:
			result.sprite_node.set_meta("instance_id", prefab_instance.instance_id)
			sprite_nodes.append(result.sprite_node)

	# Stocker les sprites dans les métadonnées de la zone
	if sprite_nodes.size() > 0:
		zone.set_meta("sprite_nodes", sprite_nodes)
	
	return zone
