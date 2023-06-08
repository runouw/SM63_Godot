@tool
extends Node2D

@export var attach: bool = true
@export_file("*.xml") var source_xml: String
@export var run_convert: bool = false:
	set(to):
		if to:
			_run()
		run_convert = false


func _ready():
	if not Engine.is_editor_hint():
		_run()


func _run():
	if attach:
		while get_child_count() > 0:
			remove_child(get_child(0))
	
	if source_xml.ends_with(".xml"):
		_parse_xml(source_xml)
	else:
		var dir := DirAccess.open(source_xml)
		for file in dir.get_files():
			_parse_xml(source_xml + "/" + file)


func _parse_xml(path):
	var output_path = XFLUtils.convert_xfl_file(path)
	
	if attach:
		var instance = load(output_path).instantiate()
		add_child(instance)
		instance.owner = self
