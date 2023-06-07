@tool
extends Node2D

@export_file var source_xml: String

# Called when the node enters the scene tree for the first time.
func _ready():
	while get_child_count() > 0:
		remove_child(get_child(0))
	
	var output_path = XFLUtils.convert_xfl_file(source_xml)
	
	var instance = load(output_path).instantiate()
	add_child(instance)
	instance.owner = self
	
	
