class_name XFLUtils

const root_folder: String = "res://sm63/LIBRARY"
const output_folder: String = "res://sm63_godot"

static func convert_xfl_file(path: String) -> String:
	print(path)
	
	var parser = XMLParser.new()
	
	var error = parser.open(path)
	if error != 0:
		print("error ", error)
		return ""
	
	var model = XmlModel.new(parser)
	
	match(model.root.name):
		"DOMSymbolItem":
			return _generate_DOMSymbolItem_scene(path, model.root)
		_:
			print(model.root.name, " not handled!")
	
	return ""


static func _generate_DOMSymbolItem_scene(path: String, DOMSymbolItem: XMLNode) -> String:
	var output_path = path.replace(root_folder, output_folder)
	output_path = output_path.trim_suffix(".xml") + ".tscn"
	
	var containing_folder = output_path.trim_suffix(output_path.get_file())
	
	if not DirAccess.dir_exists_absolute(containing_folder):
		DirAccess.make_dir_recursive_absolute(containing_folder)
	
	print("-> ", output_path)
	
	var new_node := Process_DOMSymbolItem.new(path)
	
	new_node.set_script(null)
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(new_node)
	var error := ResourceSaver.save(packed_scene, output_path)
	if error != OK:
		print("Error saving ", error)
	
	return output_path


static func fix_image_path(path: String) -> String:
	var path_arr: PackedStringArray = path.split("/")
	for i in range(path_arr.size()):
		path_arr[i] = _fix_dir_name(path_arr[i])
	
	return "sm63/LIBRARY/%s.png" % ["/".join(path_arr)]


static func fix_symbol_path(path: String) -> String:
	var path_arr: PackedStringArray = path.split("/")
	for i in range(path_arr.size()):
		path_arr[i] = _fix_dir_name(path_arr[i])
	
	return "res://sm63_godot/%s.tscn" % ["/".join(path_arr)]


static func _fix_dir_name(str) -> String:
	str = str.strip_edges()
	str = str.replace(",", "&#044")
	str = str.replace(":", "&#058")
	str = str.replace("\"", "&#034")
	return str
