extends Node2D

@export_dir var root_folder: String
@export_dir var output_folder: String

# Called when the node enters the scene tree for the first time.
func _ready():
	_explore_dir(root_folder)
	
	


func _explore_dir(path: String):
	var dir_access := DirAccess.open(path)
	
	var directories := dir_access.get_directories()
	var files := dir_access.get_files()
	
	for file in files:
		if file.ends_with(".xml"):
			_explore_xml(path + "/" + file)
	
	for directory in directories:
		_explore_dir(path + "/" + directory)


func _explore_xml(path: String):
	print(path)
	
	var parser = XMLParser.new()
	
	var error = parser.open(path)
	if error != 0:
		print("error ", error)
		return
	
	var model = XmlModel.new(parser)
	
	match(model.root.name):
		"DOMSymbolItem":
			_parse_DOMSymbolItem(path, model.root)
		_:
			print(model.root.name, " not handled!")


func _parse_DOMSymbolItem(path: String, DOMSymbolItem: XMLNode):
	var output_path = path.replace(root_folder, output_folder)
	output_path = output_path.trim_suffix(".xml") + ".tscn"
	
	print(root_folder)
	print("  ", output_path)
	
	var new_node := Process_DOMSymbolItem.new(path)
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(new_node)
	ResourceSaver.save(packed_scene, output_path)
