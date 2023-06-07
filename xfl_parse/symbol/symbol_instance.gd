@tool
extends Node2D

@export_file var path: String = ""

func _ready():
	if get_child_count() > 0:
		return
	
	await get_tree().physics_frame
	
	if not path.is_empty():
		var packed_scene = load(path)
		if packed_scene:
			var instance = packed_scene.instantiate()
			add_child(instance)
			instance.owner = owner
