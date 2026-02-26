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
	for prefab_instance in zone.prefab_instances:
		var prefab_elements = PrefabLoader.load_and_instantiate(prefab_instance)
		zone.elements.append_array(prefab_elements)
	
	return zone
