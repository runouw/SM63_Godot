class_name XFLUtils

const root_folder: String = "res://sm63"
const output_folder: String = "res://sm63_converted"

static func convert_xfl_file(path: String) -> Node2D:
	print(path)
	
	var parser = XMLParser.new()
	
	var error = parser.open(path)
	if error != 0:
		print_debug("error ", error)
		return null
	
	var model = XmlModel.new(parser)
	
	match(model.root.name):
		"DOMSymbolItem":
			return _generate_DOMSymbolItem_scene(path, model.root)
		"DOMDocument":
			return _generate_DOMSymbolItem_scene(path, model.root)
		_:
			print_debug(model.root.name, " not handled!")
	
	return null


static func _generate_DOMSymbolItem_scene(path: String, DOMSymbolItem: XMLNode) -> Node2D:
	var output_path = xml_to_tscn_path(path)
	
	var containing_folder = output_path.trim_suffix(output_path.get_file())
	
	if not DirAccess.dir_exists_absolute(containing_folder):
		DirAccess.make_dir_recursive_absolute(containing_folder)
	
	print("-> ", output_path)
	
	var processor := Process_DOMSymbolItem.new(path)
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(processor.root_node)
	var error := ResourceSaver.save(packed_scene, output_path)
	if error != OK:
		print("Error saving ", error)
	
	return processor.root_node

static func xml_to_tscn_path(xml_path: String) -> String:
	var output_path = xml_path.replace(root_folder, output_folder)
	output_path = output_path.trim_suffix(".xml") + ".tscn"
	return output_path


static func fix_image_path(path: String) -> String:
	var path_arr: PackedStringArray = path.split("/")
	for i in range(path_arr.size()):
		path_arr[i] = _fix_dir_name(path_arr[i])
	
	return "%s/LIBRARY/%s.png" % [root_folder, "/".join(path_arr)]


static func fix_symbol_path(path: String) -> String:
	var path_arr: PackedStringArray = path.split("/")
	for i in range(path_arr.size()):
		path_arr[i] = _fix_dir_name(path_arr[i])
	
	return "%s/LIBRARY/%s.tscn" % [output_folder, "/".join(path_arr)]


static func _fix_dir_name(str) -> String:
	str = str.strip_edges()
	str = str.replace(",", "&#044")
	str = str.replace(":", "&#058")
	str = str.replace("\"", "&#034")
	return str
