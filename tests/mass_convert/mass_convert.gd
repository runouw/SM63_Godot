extends Node2D

func _ready():
	_explore_dir(XFLUtils.root_folder)
	print("DONE!")


func _explore_dir(path: String):
	var dir_access := DirAccess.open(path)
	if dir_access == null:
		print(DirAccess.get_open_error())
	
	var directories := dir_access.get_directories()
	var files := dir_access.get_files()
	
	for file in files:
		if file.ends_with(".xml"):
			XFLUtils.convert_xfl_file(path + "/" + file)
	
	for directory in directories:
		_explore_dir(path + "/" + directory)
