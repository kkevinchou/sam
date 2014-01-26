uniform number width;
uniform number height;
uniform number diff;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
	vec4 l = Texel(texture, texture_coords - vec2(1/width,0));
	vec4 r = Texel(texture, texture_coords + vec2(1/width,0));
	vec4 u = Texel(texture, texture_coords - vec2(0,1/height));
	vec4 d = Texel(texture, texture_coords + vec2(0,1/height));
	return color * (diff*(l+r+u+d)+Texel(texture, texture_coords))/(1+diff*4);
}