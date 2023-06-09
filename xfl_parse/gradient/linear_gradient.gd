@tool
extends Polygon2D

@export var matrix: Transform2D
@export var entries_color: PackedColorArray
@export var entries_ratio: PackedFloat32Array

@export var spread_method_reflect: bool = false
@export var spread_method_repeat: bool = false

func _ready():
	material = load("res://xfl_parse/gradient/linear_gradient_material.tres").duplicate()

	material.set_shader_parameter("transformMatrix", matrix.affine_inverse())

	var gradient := Gradient.new()
	gradient.colors = entries_color
	gradient.offsets = entries_ratio

	var gradientTexture := GradientTexture1D.new()
	gradientTexture.gradient = gradient

	material.set_shader_parameter("gradientTexture", gradientTexture)
	
	material.set_shader_parameter("spreadMethodReflect", spread_method_reflect)
	material.set_shader_parameter("spreadMethodRepeat", spread_method_repeat)
