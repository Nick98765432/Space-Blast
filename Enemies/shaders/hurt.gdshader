shader_type canvas_item;

uniform float shake_power = 0.03;
uniform float shake_rate : hint_range(0.0, 1.0) = 0.2;
uniform float shake_speed = 5.0;
uniform float shake_block_size = 30.5;
uniform float shake_color_rate : hint_range(0.0, 1.0) = 0.01;

uniform vec4 flashColour : source_color = vec4(1.0);
uniform float mixAmount = 0.9;

float random(float seed) {
    return fract(543.2543 * sin(dot(vec2(seed, seed), vec2(3525.46, -54.3415))));
}

void fragment() {
    // Base sprite
    vec4 base = texture(TEXTURE, UV);

    // Shake enable
    float enable_shift = float(random(floor(TIME * shake_speed)) < shake_rate);

    // Distorted UV
    vec2 uv = UV;
    uv.x += (random(floor(UV.y * shake_block_size) / shake_block_size + TIME) - 0.5)
            * shake_power * enable_shift;

    vec4 glitch = texture(TEXTURE, uv);

    // Blend base + glitch
    vec4 color = mix(base, glitch, enable_shift);

    // Flash overlay (final stage)
    color.rgb = mix(color.rgb, flashColour.rgb, mixAmount);

    COLOR = color;
}