extends Node2D

var linkages = {}

func _ready():
	_explore_dir(XFLUtils.root_folder)
	
	_generate_linkages()
	
	print("DONE CONVERTING!")


func _explore_dir(path: String):
	var dir_access := DirAccess.open(path)
	if dir_access == null:
		print(DirAccess.get_open_error())
	
	var directories := dir_access.get_directories()
	var files := dir_access.get_files()
	
	for file in files:
		if file.ends_with(".xml"):
			var res_path: String = path + "/" + file
			
			var node = XFLUtils.convert_xfl_file(path + "/" + file)
			
			if node and node.linkage_export:
				linkages[node.linkage] = res_path
	
	for directory in directories:
		_explore_dir(path + "/" + directory)


func _generate_linkages():
	var result_path = "res://sm63_converted/linkages.tscn"
	
	var root_node := Node2D.new()
	root_node.set_script(load("res://xfl_parse/linkages/linkages.gd"))
	root_node.linkages = linkages
	
	var packed_scene = PackedScene.new()
	packed_scene.pack(root_node)
	var error := ResourceSaver.save(packed_scene, result_path)
	if error != OK:
		print("Error saving ", error)
