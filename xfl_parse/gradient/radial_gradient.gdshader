// NOTE: Shader automatically converted from Godot Engine 4.0.3.stable's CanvasItemMaterial.

shader_type canvas_item;
render_mode blend_mix;

uniform mat4 transformMatrix;
uniform float focalPointRatio;
uniform float radius = 5.0;
uniform sampler2D gradientTexture: repeat_enable, filter_linear_mipmap;

varying vec2 vert;

void vertex() {
	vert = VERTEX.xy;
}

void fragment() {
	vec4 puv = transformMatrix * vec4(vert.xy, 0.0, 1.0);
	vec2 uv = puv.xy / puv.w;
	
	float y = -focalPointRatio * radius;
	float r = radius;
	
	vec2 d = vec2(0.0, focalPointRatio) - uv.xy;
	float l = length(d);
	d /= l;
	
	float g = 1.0 / max(1.0, sqrt(r * r - y * y * d.x * d.x) / l + y * d.y / l);
	
	COLOR = texture(gradientTexture, vec2(g, 0.5));
}