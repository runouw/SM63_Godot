@tool
extends Polygon2D

@export var matrix: Transform2D
@export var entries_color: PackedColorArray
@export var entries_ratio: PackedFloat32Array

# The value range is from -1.0 to 1.0, where -1.0 means the focal point is close to the left border of the radial
# gradient circle, 0.0 means that the focal point is in the center of the radial gradient circle, and 1.0 means that
# the focal point is close to the right border of the radial gradient circle.
@export var focal_point_ratio: float = 0.0

func _ready():
	material = load("res://xfl_parse/gradient/radial_gradient_material.tres").duplicate()

	material.set_shader_parameter("transformMatrix", matrix.affine_inverse())

	var gradient := Gradient.new()
	gradient.colors = entries_color
	gradient.offsets = entries_ratio

	var gradientTexture := GradientTexture1D.new()
	gradientTexture.gradient = gradient

	material.set_shader_parameter("gradientTexture", gradientTexture)
	material.set_shader_parameter("focalPointRatio", focal_point_ratio)
