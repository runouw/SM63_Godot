// NOTE: Shader automatically converted from Godot Engine 4.0.3.stable's CanvasItemMaterial.

shader_type canvas_item;
render_mode blend_mix;

uniform mat4 transformMatrix;
uniform float focalPointRatio;
uniform float radius = 1024.0;
uniform sampler2D gradientTexture: filter_linear_mipmap;

varying vec2 vert;

void vertex() {
	vert = VERTEX.xy;
}

void fragment() {
	vec4 puv = transformMatrix * vec4(vert.xy, 0.0, 1.0);
	vec2 uv = puv.xy / puv.w;
	
	float fr = focalPointRatio;
	
	float r = radius;
	float y = fr * r;
	
	vec2 d = vec2(0.0, fr * r) - uv.xy;
	float l = length(d);
	d /= l;

	float g = 1.0 / max(1.0, (sqrt(max(r * r - y * y * d.x * d.x, 0.0)) + y * d.y) / l);

	COLOR *= texture(gradientTexture, vec2(g, 0.5));
}