if (instance_exists(follow_target)) {
    x_to = follow_target.x;
    y_to = follow_target.y;
}

// Smooth Movement (Independent of framerate)
// Lerp is frame-dependent.
// Correct formula for frame-independent damping: a = lerp(a, b, 1 - exp(-decay * dt))

x += (x_to - x) * (1 - exp(-CAMERA_SMOOTH_DECAY * global.dt));
y += (y_to - y) * (1 - exp(-CAMERA_SMOOTH_DECAY * global.dt));

// Clamp to Room
var _cam_w = camera_get_view_width(view_camera[0]);
var _cam_h = camera_get_view_height(view_camera[0]);
var _half_w = _cam_w * 0.5;
var _half_h = _cam_h * 0.5;

x = clamp(x, _half_w, room_width - _half_w);
y = clamp(y, _half_h, room_height - _half_h);

// Pixel Perfect Rounding (The "Trick")
// We update the view position to rounded coordinates to avoid sub-pixel rendering artifacts
var _cam_x = x - _half_w;
var _cam_y = y - _half_h;

camera_set_view_pos(view_camera[0], floor(_cam_x), floor(_cam_y));
