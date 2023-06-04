// NOTE: Shader automatically converted from Godot Engine 4.0.3.stable's CanvasItemMaterial.

shader_type canvas_item;
render_mode blend_mix;

uniform mat4 transformMatrix;
uniform sampler2D gradientTexture: repeat_enable, filter_linear_mipmap;

varying vec2 vert;

void vertex() {
	vert = VERTEX.xy / 5.0;
}

void fragment() {
	vec2 uv = (mat3(transformMatrix) * vec3(vert.xy, 1.0)).xy;
	
	float d = fract(length(uv));
	
	COLOR = texture(gradientTexture, vec2(d, 0.5));
}