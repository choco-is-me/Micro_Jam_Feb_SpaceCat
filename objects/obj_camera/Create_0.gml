// Camera Properties
view_width = 480;
view_height = 270;
window_scale = 3;

// Set Window Size
window_set_size(view_width * window_scale, view_height * window_scale);
surface_resize(application_surface, view_width * window_scale, view_height * window_scale);
alarm[0] = 1; // Center window

// Enable Views
camera_set_view_size(view_camera[0], view_width, view_height);
view_enabled = true;
view_visible[0] = true;

// Following
follow_target = obj_player;
x_to = x;
y_to = y;
camera_spd = 0.1; // Smoothness factor (lower = smoother/slower)
