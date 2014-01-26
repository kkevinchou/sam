uniform number intensity = 1;
uniform number rf_w = 512;
uniform number rf_h = 512;

const number offset[3] = number[](0.0, 1.3846153846, 3.2307692308);
const number weight[3] = number[](0.2270270270, 0.3162162162, 0.0702702703);
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
	vec4 tc = Texel(texture,texture_coords) * weight[0];
	tc += Texel(texture,texture_coords+intensity*vec2(offset[1],0)/rf_w)*weight[1]*0.5;
	tc += Texel(texture,texture_coords-intensity*vec2(offset[1],0)/rf_w)*weight[1]*0.5;

	tc += Texel(texture,texture_coords+intensity*vec2(offset[2],0)/rf_w)*weight[2]*0.5;
	tc += Texel(texture,texture_coords-intensity*vec2(offset[2],0)/rf_w)*weight[2]*0.5;

	tc += Texel(texture,texture_coords+intensity*vec2(0,offset[1])/rf_h)*weight[1]*0.5;
	tc += Texel(texture,texture_coords-intensity*vec2(0,offset[1])/rf_h)*weight[1]*0.5;

	tc += Texel(texture,texture_coords+intensity*vec2(0,offset[2])/rf_h)*weight[2]*0.5;
	tc += Texel(texture,texture_coords-intensity*vec2(0,offset[2])/rf_h)*weight[2]*0.5;

	return color * tc;
}