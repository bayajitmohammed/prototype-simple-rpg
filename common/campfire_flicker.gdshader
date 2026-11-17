shader_type canvas_item;

void fragment() {
	vec4 original = texture(TEXTURE, UV);
	float warm = smoothstep(0.12, 0.38, original.r - original.b)
		* smoothstep(0.38, 0.70, original.r);
	float flame = warm * smoothstep(0.02, 0.18, original.g - original.b);

	// Move only the warm fire pixels; keep the stone and logs steady.
	float sway = sin(TIME * 4.7 + UV.y * 180.0)
		* sin(TIME * 2.9 + UV.x * 120.0);
	vec2 offset = vec2(
		sway * 1.8,
		sin(TIME * 6.1 + UV.x * 150.0) * 0.7
	) * TEXTURE_PIXEL_SIZE;
	vec4 moved = texture(TEXTURE, UV + offset);
	vec4 result = mix(original, moved, flame * 0.8);

	float flicker = 0.5 + 0.25 * sin(TIME * 9.1 + UV.x * 75.0)
		+ 0.25 * sin(TIME * 5.7 + UV.y * 110.0);
	result.rgb += vec3(0.16, 0.07, 0.0) * flame * flicker;
	COLOR = result;
}
