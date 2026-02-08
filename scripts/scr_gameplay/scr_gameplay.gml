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

/// @function scr_is_spawn_position_valid(_x, _y, _check_radius)
/// @description Checks if a spawn position is free from collisions with other objects
/// @param {Real} _x X position to check
/// @param {Real} _y Y position to check
/// @param {Real} _check_radius Radius to check for collisions
/// @return {Bool} True if position is valid (no collisions), false otherwise
function scr_is_spawn_position_valid(_x, _y, _check_radius) {
    // Check for collision with solid obstacles (trees, campfire)
    if (collision_circle(_x, _y, _check_radius, par_obstacle, false, true) != noone) {
        return false;
    }
    
    // Check for collision with decorative objects (bush, grass, flower)
    if (collision_circle(_x, _y, _check_radius, obj_bush, false, true) != noone) {
        return false;
    }
    if (collision_circle(_x, _y, _check_radius, obj_grass, false, true) != noone) {
        return false;
    }
    if (collision_circle(_x, _y, _check_radius, obj_flower, false, true) != noone) {
        return false;
    }
    
    // Check for collision with collectibles (sticks, clues)
    if (collision_circle(_x, _y, _check_radius, obj_stick, false, true) != noone) {
        return false;
    }
    if (collision_circle(_x, _y, _check_radius, obj_clue, false, true) != noone) {
        return false;
    }
    
    // Check for collision with player (shouldn't spawn on player)
    if (collision_circle(_x, _y, _check_radius, obj_player, false, true) != noone) {
        return false;
    }
    
    // Position is valid
    return true;
}
