uniform number width;
uniform number height;
uniform number diff;
uniform Image velocityField;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
	vec2 final = texture_coords + (Texel(velocityField, texture_coords).rg - vec2(.5,.5)) * diff * vec2(1/width,1/height);
	return color * Texel(texture, final);
}