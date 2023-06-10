shader_type canvas_item;
render_mode blend_mix;

uniform mat4 transformMatrix;
uniform float focalPointRatio;
uniform float radius = 824.0;
uniform sampler2D gradientTexture: repeat_enable, filter_linear;

uniform bool spreadMethodReflect = false;
uniform bool spreadMethodRepeat = false;

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
	
	vec2 d = vec2(fr * r, 0.0) - uv.xy;
	float l = length(d);
	d /= l;

	float f = (sqrt((r * r - y * y * d.y * d.y)) + y * d.x) / l;
	float h = 1.0 / max(f, 1e-9);
	
	// calculate coords for all 3 spread modes
	float default_coord = clamp(h, 1.0 / 256.0, 255.0 / 256.0); // texture is 256px
	float repeat_coord = h;
	float reflect_coord = abs(mod((h * 0.5 - 0.5) * 2.0, 2.0) - 1.0) * 255.0 / 256.0 + 1.0 / 512.0;
	
	float coord = default_coord;
	
	// mix(a, b, float(my_boolean)) is said to be faster than an if statement
	coord = mix(coord, repeat_coord, float(spreadMethodRepeat));
	coord = mix(coord, reflect_coord, float(spreadMethodReflect));

	COLOR *= texture(gradientTexture, vec2(coord, 0.5));
}