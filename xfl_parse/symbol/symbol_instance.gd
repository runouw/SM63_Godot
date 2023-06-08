@tool
extends Node2D

@export_file var path: String = ""

@export var red_multiplier: float = 1.0
@export var green_multiplier: float = 1.0
@export var blue_multiplier: float = 1.0
@export var alpha_multiplier: float = 1.0

@export var red_offset: float = 0.0
@export var green_offset: float = 0.0
@export var blue_offset: float = 0.0

@export var tint_multiplier: float = 0.0
@export var tint_color: Color = Color.BLACK
@export var brightness: float = 0.0

var _loaded: bool = false

func _ready():
	_update_color()
	
	var has_instance_already: bool = false
	for child in get_children():
		if child is Node2D:
			has_instance_already = true
			break
	
	if has_instance_already:
		_loaded = true
		return
	
	await get_tree().physics_frame
	
	if is_visible_in_tree():
		_do_load()
	
	visibility_changed.connect(func():
		if is_inside_tree() and is_visible_in_tree() and _loaded == false:
			_do_load()
		if is_inside_tree() and not is_visible_in_tree() and _loaded == true:
			_do_unload()
	)


func _update_color():
	if not is_inside_tree():
		return
	
	modulate = Color.WHITE
	
	if red_offset > 0 or green_offset > 0 or blue_offset > 0:
		# TODO: apply color _offset...
		pass
	
	if tint_multiplier > 0.0:
		modulate = lerp(Color.WHITE, tint_color, tint_multiplier)
	
	modulate.r *= red_multiplier
	modulate.g *= green_multiplier
	modulate.b *= blue_multiplier
	modulate.a *= alpha_multiplier
	
	var br = pow(abs(brightness), 2.2) * sign(brightness)
	modulate.r *= brightness + 1.0
	modulate.g *= brightness + 1.0
	modulate.b *= brightness + 1.0


func _do_load():
	_loaded = true
	if not path.is_empty():
		var packed_scene = load(path)
		if packed_scene:
			var instance = packed_scene.instantiate()
			add_child(instance)
			instance.owner = owner


func _do_unload():
	_loaded = false
	
	for child in get_children():
		if child is Node2D:
			child.queue_free()
