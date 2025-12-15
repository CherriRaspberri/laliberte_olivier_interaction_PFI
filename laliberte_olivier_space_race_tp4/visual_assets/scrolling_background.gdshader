shader_type canvas_item;

uniform vec2 direction = vec2(0.0, -1.0);
uniform float speed_scale = 0.3;

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 move = direction * TIME * speed_scale;
	vec2 uv = fract(UV + move);
	COLOR = texture(TEXTURE, uv);
}