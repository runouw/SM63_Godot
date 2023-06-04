extends Node2D

@export_file("*.xml") var back_gfx_path
@export_file("*.xml") var front_gfx_path
@export_file("*.tscn") var export_path


func _ready():
	var backGFX = Process_DOMSymbolItem.new(back_gfx_path)
	var frontGFX = Process_DOMSymbolItem.new(front_gfx_path)
	
	$Container.add_child(backGFX)
	$Container.add_child(frontGFX)
	
	_recursively_set_owner($Container, $Container)
	
	var packed_scene = PackedScene.new()
	packed_scene.pack($Container)
	var error := ResourceSaver.save(packed_scene, export_path)
	if error != OK:
		print("Error saving ", error)


func _recursively_set_owner(root: Node, owner: Node) -> void:
	for child in root.get_children():
		child.owner = owner
		_recursively_set_owner(child, owner)
