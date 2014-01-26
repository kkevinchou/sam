vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
	vec4 tex = Texel(texture, texture_coords);
	return color * vec4(tex.g,tex.g,tex.b,tex.r);
}