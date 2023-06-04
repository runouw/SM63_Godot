extends Node2D

@export_file("*.xml") var back_gfx_path
@export_file("*.xml") var front_gfx_path


func _ready():
	$Container.add_child(Process_DOMSymbolItem.new(back_gfx_path))
	$Container.add_child(Process_DOMSymbolItem.new(front_gfx_path))
