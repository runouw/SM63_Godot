shader_type canvas_item;
render_mode blend_mix;

uniform mat4 transformMatrix;
uniform sampler2D gradientTexture: repeat_enable, filter_linear_mipmap;

uniform bool spreadMethodReflect = false;
uniform bool spreadMethodRepeat = false;

varying vec2 vert;

void vertex() {
	vert = VERTEX.xy / 2000.0;
}

void fragment() {
	vec2 uv = (mat3(transformMatrix) * vec3(vert.xy, 1.0)).xy;
	
	float default_coord = clamp(uv.x, 1.0 / 256.0, 255.0 / 256.0); // texture is 256px
	float repeat_coord = uv.x;
	float reflect_coord = abs(mod((uv.x * 0.5 - 0.5) * 2.0, 2.0) - 1.0) * 255.0 / 256.0 + 1.0 / 512.0;
	
	float coord = default_coord;
	
	// mix(a, b, float(my_boolean)) is said to be faster than an if statement
	coord = mix(coord, repeat_coord, float(spreadMethodRepeat));
	coord = mix(coord, reflect_coord, float(spreadMethodReflect));
	
	COLOR *= texture(gradientTexture, vec2(coord, 0.5));
}