class_name XFLUtils


static func fix_image_path(path: String) -> String:
	print(path)
	var path_arr: PackedStringArray = path.split("/")
	for i in range(path_arr.size()):
		var str = path_arr[i].strip_edges()
		str = str.replace(",", "&#044")
		
		path_arr[i] = str
	
	return "sm63/LIBRARY/%s.png" % ["/".join(path_arr)]
