/// @description End Draw - Apply shader and render surface

// Only apply shader in Room1 (gameplay room)
if (room != Room1 || !SHADER_ENABLED || !shader_is_compiled(shd_lighting)) {
    exit;
}

// Stop capturing to surface
surface_reset_target();

// Don't apply shader if surface is invalid
if (!surface_exists(shader_surface)) {
    exit;
}

// Collect all light sources
var _lights_pos = [];
var _lights_col = [];
var _lights_rad = [];
var _lights_int = [];
var _num_lights = 0;

// Get camera position for converting world to screen coordinates
var _cam = view_camera[0];
var _cam_x = camera_get_view_x(_cam);
var _cam_y = camera_get_view_y(_cam);

// Helper function to add light
var add_light = function(_world_x, _world_y, _radius, _intensity, _r, _g, _b, _cam_x, _cam_y, _lights_pos, _lights_col, _lights_rad, _lights_int, _num_lights) {
    // Convert world position to screen space
    var _screen_x = _world_x - _cam_x;
    var _screen_y = _world_y - _cam_y;
    
    // Add light data
    array_push(_lights_pos, _screen_x, _screen_y);
    array_push(_lights_col, _r, _g, _b);
    array_push(_lights_rad, _radius);
    array_push(_lights_int, _intensity);
    
    return _num_lights + 1;
};

// 1. CAMPFIRE LIGHT (Dynamic radius based on fuel)
if (instance_exists(obj_campfire)) {
    var _camp = instance_find(obj_campfire, 0);
    
    // Calculate dynamic radius based on fuel level
    var _fuel_ratio = clamp(global.fuel / FUEL_MAX, 0, 1);
    var _camp_radius = lerp(LIGHT_CAMPFIRE_RADIUS_MIN, LIGHT_CAMPFIRE_RADIUS_BASE, _fuel_ratio);
    var _camp_intensity = LIGHT_CAMPFIRE_INTENSITY * (0.3 + _fuel_ratio * 0.7); // Dims to 30% at 0 fuel
    
    // Use visual center (matches interaction/light calculations)
    var _camp_x = _camp.x;
    var _camp_y = _camp.y - (_camp.sprite_height - CAMPFIRE_LIGHT_CENTER_OFFSET * _camp.image_yscale);
    
    _num_lights = add_light(_camp_x, _camp_y, _camp_radius, _camp_intensity, 
                            LIGHT_CAMPFIRE_COLOR_R, LIGHT_CAMPFIRE_COLOR_G, LIGHT_CAMPFIRE_COLOR_B,
                            _cam_x, _cam_y, _lights_pos, _lights_col, _lights_rad, _lights_int, _num_lights);
}

// 2. PLAYER LIGHT
if (instance_exists(obj_player)) {
    var _player = instance_find(obj_player, 0);
    _num_lights = add_light(_player.x, _player.y, LIGHT_PLAYER_RADIUS, LIGHT_PLAYER_INTENSITY,
                            LIGHT_PLAYER_COLOR_R, LIGHT_PLAYER_COLOR_G, LIGHT_PLAYER_COLOR_B,
                            _cam_x, _cam_y, _lights_pos, _lights_col, _lights_rad, _lights_int, _num_lights);
}

// 3. ENEMY LIGHT
with (obj_enemy) {
    _num_lights = add_light(x, y, LIGHT_ENEMY_RADIUS, LIGHT_ENEMY_INTENSITY,
                            LIGHT_ENEMY_COLOR_R, LIGHT_ENEMY_COLOR_G, LIGHT_ENEMY_COLOR_B,
                            _cam_x, _cam_y, _lights_pos, _lights_col, _lights_rad, _lights_int, _num_lights);
}

// 4. CLUE LIGHTS
with (obj_clue) {
    if (_num_lights >= 16) break; // Max light limit
    _num_lights = add_light(x, y, LIGHT_CLUE_RADIUS, LIGHT_CLUE_INTENSITY,
                            LIGHT_CLUE_COLOR_R, LIGHT_CLUE_COLOR_G, LIGHT_CLUE_COLOR_B,
                            _cam_x, _cam_y, _lights_pos, _lights_col, _lights_rad, _lights_int, _num_lights);
}

// 5. STICK LIGHTS
with (obj_stick) {
    if (_num_lights >= 16) break; // Max light limit
    _num_lights = add_light(x, y, LIGHT_STICK_RADIUS, LIGHT_STICK_INTENSITY,
                            LIGHT_STICK_COLOR_R, LIGHT_STICK_COLOR_G, LIGHT_STICK_COLOR_B,
                            _cam_x, _cam_y, _lights_pos, _lights_col, _lights_rad, _lights_int, _num_lights);
}

// Apply shader and set uniforms
shader_set(shd_lighting);

var _view_w = camera_get_view_width(_cam);
var _view_h = camera_get_view_height(_cam);

// Set shader uniforms
shader_set_uniform_f(uni_resolution, _view_w, _view_h);
shader_set_uniform_f(uni_ambient, SHADER_AMBIENT_DARKNESS);
shader_set_uniform_f(uni_vignette, SHADER_VIGNETTE_STRENGTH);
shader_set_uniform_i(uni_num_lights, _num_lights);

// Pass light arrays (pad to 16 lights)
if (_num_lights > 0) {
    shader_set_uniform_f_array(uni_light_positions, _lights_pos);
    shader_set_uniform_f_array(uni_light_colors, _lights_col);
    shader_set_uniform_f_array(uni_light_radii, _lights_rad);
    shader_set_uniform_f_array(uni_light_intensities, _lights_int);
}

// Draw the surface with shader applied
draw_surface(shader_surface, _cam_x, _cam_y);

// Reset shader
shader_reset();
