shader_type canvas_item;

void fragment() {
	vec4 samp = texture(TEXTURE, UV);
	if (samp.x == 1.0 && samp.y == 0.0 && samp.z == 1.0) {
		samp = vec4(0.0, 0.0, 0.0, 0.0);
	}
	COLOR = samp;
}
