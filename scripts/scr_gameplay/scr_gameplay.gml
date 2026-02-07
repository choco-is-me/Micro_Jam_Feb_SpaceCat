/// @function scr_move_and_collide(_vx, _vy, _collision_obj)
/// @description Moves the calling instance, handling collision and sliding.
/// @param {Real} _vx X velocity
/// @param {Real} _vy Y velocity
/// @param {Id.Instance|Id.Object} _collision_obj Object to collide with (e.g., par_obstacle)

function scr_move_and_collide(_vx, _vy, _collision_obj) {
    // Horizontal Collision
    if (place_meeting(x + _vx, y, _collision_obj)) {
        while (!place_meeting(x + sign(_vx), y, _collision_obj)) {
            x += sign(_vx);
        }
        _vx = 0;
    }
    x += _vx;

    // Vertical Collision
    if (place_meeting(x, y + _vy, _collision_obj)) {
        while (!place_meeting(x, y + sign(_vy), _collision_obj)) {
            y += sign(_vy);
        }
        _vy = 0;
    }
    y += _vy;
}

/// @function scr_update_depth()
/// @description Updates depth based on bottom bounding box for Y-sorting
function scr_update_depth() {
    depth = -bbox_bottom;
}
