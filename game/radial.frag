uniform vec2 center;
uniform number range;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
	number opacity = 1-sqrt((dot(screen_coords - center, screen_coords - center) / (range * range / 10)));
	return vec4((color * Texel(texture, texture_coords)).rgb, 0.3+opacity*0.5);
}