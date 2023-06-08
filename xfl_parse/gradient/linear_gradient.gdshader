// NOTE: Shader automatically converted from Godot Engine 4.0.3.stable's CanvasItemMaterial.

shader_type canvas_item;
render_mode blend_mix;

uniform mat4 transformMatrix;
uniform sampler2D gradientTexture: repeat_enable, filter_linear_mipmap;

uniform bool spreadMethodReflect = false;

varying vec2 vert;

void vertex() {
	vert = VERTEX.xy / 2000.0;
}

void fragment() {
	vec2 uv = (mat3(transformMatrix) * vec3(vert.xy, 1.0)).xy;
	
	// this is faster than an if statement
	uv.x = mix(uv.x, abs(mod((uv.x + 0.5) * 2.0, 2.0) - 1.0), float(spreadMethodReflect));
	
	COLOR *= texture(gradientTexture, vec2(uv.x, 0.5));
}