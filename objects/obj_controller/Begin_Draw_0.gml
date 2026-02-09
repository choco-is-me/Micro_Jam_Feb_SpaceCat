/// @description Begin Draw - Start surface capture for shader

// Only apply shader in Room1 (gameplay room)
if (room != Room1 || !SHADER_ENABLED || !shader_is_compiled(shd_lighting)) {
    exit;
}

// Get camera view dimensions
var _view_w = camera_get_view_width(view_camera[0]);
var _view_h = camera_get_view_height(view_camera[0]);

// Create or resize surface if needed
if (!surface_exists(shader_surface)) {
    shader_surface = surface_create(_view_w, _view_h);
}

// Ensure surface is correct size (handles window resize)
if (surface_get_width(shader_surface) != _view_w || surface_get_height(shader_surface) != _view_h) {
    surface_resize(shader_surface, _view_w, _view_h);
}

// Start capturing to surface
surface_set_target(shader_surface);
draw_clear_alpha(c_black, 0); // Clear with transparency
