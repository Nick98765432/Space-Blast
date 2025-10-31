shader_type canvas_item;
uniform vec4 flashColour = vec4(1.0);
uniform float mixAmount = 0.9;
void fragment() {
	vec4 colour = texture(TEXTURE, UV);
	colour.rgb = mix(colour.rgb,flashColour.rgb,mixAmount);
	COLOR = colour;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
