// Blurs and tints whatever was drawn before this node. Used as the popup backdrop.
shader_type canvas_item;

// Compatibility renderer has no mipmaps for the screen texture, so textureLod() can't blur.
// A box blur with explicit samples works on every renderer.
uniform sampler2D screen_texture : hint_screen_texture, filter_linear;
// Samples per side are radius * 2 + 1, so 3 means 7x7 = 49 samples.
uniform int radius : hint_range(1, 6) = 3;
// Game pixels between samples. Higher spreads the blur wider for the same cost.
uniform float spread : hint_range(0.5, 4.0) = 1.5;
uniform vec4 tint : source_color = vec4(0.0, 0.0, 0.0, 0.4);

void fragment() {
	vec3 sum = vec3(0.0);
	for (int x = -radius; x <= radius; x++) {
		for (int y = -radius; y <= radius; y++) {
			vec2 offset = vec2(float(x), float(y)) * SCREEN_PIXEL_SIZE * spread;
			sum += texture(screen_texture, SCREEN_UV + offset).rgb;
		}
	}
	float side = float(radius * 2 + 1);
	vec3 blurred = sum / (side * side);
	COLOR = vec4(mix(blurred, tint.rgb, tint.a), 1.0);
}
