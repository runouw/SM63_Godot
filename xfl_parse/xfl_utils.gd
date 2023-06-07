class_name XFLUtils


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
