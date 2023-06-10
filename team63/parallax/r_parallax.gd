@tool
extends Node2D

@export var game_resolution: Vector2 = Vector2(450.0, 300.0)

@export var move_scale: float = 1.0
# @export var zoom_scale: float = 1.0
@export var start_scale: float = 1.0

@export var zoom_strength: float = 0.0

func _process(delta):
	var p = get_parent()
	if not p:
		return
	
	var screen_size: Vector2 = get_viewport_rect().size
	
	if not Engine.is_editor_hint():
		var canvas_pos = p.get_global_transform_with_canvas().origin
		
		var canvas_scale = p.get_global_transform_with_canvas().get_scale() # matches camera node scale
		var canvas_scale_inv = Vector2(1.0 / canvas_scale.x, 1.0 / canvas_scale.y) # 1 / camera_scale
		var camera_pos = (canvas_pos) * canvas_scale_inv # matches camrea node position
		
		var local_to_global_center = Transform2D()
		local_to_global_center = local_to_global_center.scaled(Vector2.ONE * start_scale * canvas_scale_inv)
		local_to_global_center = local_to_global_center.translated_local(-camera_pos * canvas_scale)
		
		transform = Transform2D()
		
		var to_global = Transform2D()
		
		# transform = transform.rotated(Engine.get_frames_drawn() * 4e-2)
		transform = transform.scaled(Vector2.ONE * start_scale)
		transform = transform.scaled(Vector2.ONE * canvas_scale_inv)
		
		var zoom_scale: float = 1.0 - pow(zoom_strength, canvas_scale.x)
		transform = transform.scaled(Vector2.ONE * zoom_scale)
		
		transform = transform.translated(-camera_pos + screen_size / 2.0)
		transform = transform.translated((camera_pos) * move_scale)
		
	else:
		
		# print(get_viewport_rect()) # pixel size of godot viewport
		# print(get_viewport_transform()) # scales with editor zoom
		# print(p.get_global_transform()) # just parent global transform (usually identity)
		
		var trans: Transform2D = get_viewport_transform()
		var screen_center_local: Vector2 = trans.affine_inverse() * Vector2(screen_size / 2)
		var scale_editor_to_game_size := Vector2(screen_size.x / game_resolution.x, screen_size.y / game_resolution.y)
		var scale_ratio: float = scale_editor_to_game_size.y / trans.get_scale().y
		
		if not Engine.is_editor_hint():
			pass
		
		# var new_position = screen_center_local
		
		var camera_pos: Vector2 = trans.affine_inverse() * Vector2(screen_size / 2)
		var zoom_scale: float = lerp(1.0, trans.get_scale().x, zoom_strength)
		var to_global_center_space:Transform2D = trans.translated(-Vector2(screen_size / 2))
		
		var new_transform := Transform2D()
		new_transform = new_transform.scaled(Vector2.ONE * scale_ratio)
		new_transform = new_transform.translated(screen_center_local)
		
		# do these transformations in global space
		new_transform = to_global_center_space * new_transform
		new_transform = new_transform.scaled(Vector2(start_scale, start_scale) * zoom_scale)
		
		# back to local space
		new_transform = to_global_center_space.affine_inverse() * new_transform
		new_transform = new_transform.translated_local(-camera_pos * move_scale)
		
		if transform != new_transform:
			transform = new_transform
