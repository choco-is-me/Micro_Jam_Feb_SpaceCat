if (global.game_over) exit;
if (global.game_won) exit;

var _hinput = keyboard_check(global.key_right) - keyboard_check(global.key_left);
var _vinput = keyboard_check(global.key_down) - keyboard_check(global.key_up);

if (_hinput != 0 || _vinput != 0) {
    var _dir = point_direction(0, 0, _hinput, _vinput);
    var _move_amt = spd * global.dt;
    var _vx = lengthdir_x(_move_amt, _dir);
    var _vy = lengthdir_y(_move_amt, _dir);
    
    // Use collision script to slide against par_obstacle
    scr_move_and_collide(_vx, _vy, par_obstacle);
}

// Update Depth Sorting for 3D effect
scr_update_depth();

x = clamp(x, 0, room_width);

y = clamp(y, 0, room_height);

// Sanity
var campfire = instance_nearest(x, y, obj_campfire);
is_being_watched = false; // Reset state

if (campfire != noone) {
    // Check if Player Bounding Box overlaps with Campfire Light Radius
    // Campfire Center (Visual)
    var _camp_cx = campfire.x;
    var _camp_cy = campfire.y - (campfire.sprite_height / 2);
    
    // Check overlap: Returns >0 if any part of player bbox is in circle
    // If strict "whole body out" is needed for "Not Safe", then 
    // "Safe" = Any part is in. "Danger" = rectangle_in_circle == 0 (No Overlap)
    // If we want STRICT safety (whole body in), we check result == 1 (Inside).
    // Usually, "Touching light" = Safe is friendlier.
    
    var _in_light = rectangle_in_circle(bbox_left, bbox_top, bbox_right, bbox_bottom, _camp_cx, _camp_cy, campfire.light_radius);
    
    // DELTA TIME SANITY
    if (_in_light > 0) {
         global.sanity += SANITY_REGAIN_LIGHT * global.dt;
         stand_timer = 0; // Reset stand timer if safe
    } else {
         is_being_watched = true; // Player is in the dark/danger zone
         global.sanity -= SANITY_DRAIN_DARK * global.dt;
         
         // Check for Standing Still
         if (_hinput == 0 && _vinput == 0) {
             stand_timer += global.dt;
             // Active after X seconds - HARDCORE MODE
             if (stand_timer > TIME_BEFORE_STILL_PENALTY) {

                 global.sanity -= SANITY_DRAIN_STILL * global.dt;
             }
         } else {
             stand_timer = 0;
         }
    }
}

global.sanity = clamp(global.sanity, 0, SANITY_MAX);
if (global.sanity <= 0) global.game_over = true;


// --- INTERACTION SYSTEM ---
active_interact_target = noone;
active_interact_msg = "";

var _interact_range = INTERACT_RANGE;
var _closest_dist = 9999;
var _target = noone;
var _action_type = ""; // "stick", "campfire", "clue"

// Helper: Check Body Overlap with Interaction Circle
var _check_overlap = function(_tx, _ty, _radius) {
    return rectangle_in_circle(bbox_left, bbox_top, bbox_right, bbox_bottom, _tx, _ty, _radius) > 0;
};

// 1. Check Stick
var _stick = instance_nearest(x, y, obj_stick);
if (_stick != noone) {
    if (_check_overlap(_stick.x, _stick.y, _interact_range)) {
         var _d = point_distance(x, y, _stick.x, _stick.y);
         if (_d < _closest_dist) {
             if (stick_inventory < max_sticks) {
                _closest_dist = _d;
                _target = _stick;
                _action_type = "stick";
             }
         }
    }
}

// 2. Check Clue
var _clue = instance_nearest(x, y, obj_clue);
if (_clue != noone) {
    if (_check_overlap(_clue.x, _clue.y, _interact_range)) {
        var _d = point_distance(x, y, _clue.x, _clue.y);
        if (_d < _closest_dist) {
            _closest_dist = _d;
            _target = _clue;
            _action_type = "clue";
        }
    }
}

// 3. Check Campfire
if (campfire != noone) {
    // Campfire Origin = Bottom Center
    // Center of fire is roughly y - height/2
    var _camp_cx = campfire.x;
    var _camp_cy = campfire.y - (campfire.sprite_height / 2);
    
    // Check overlap with Interaction Radius
    if (_check_overlap(_camp_cx, _camp_cy, CAMPFIRE_INTERACT_RADIUS)) {
         var _d = point_distance(x, y, _camp_cx, _camp_cy);
         
        // Only prioritize if we have sticks or it's simply the closest thing
        if (stick_inventory > 0 && global.fuel < FUEL_MAX) {
            // Priority: Always allow refueling if valid, but check if we are closer to something else? 
            // Let's strictly use distance unless we want to force campfire priority.
            if (_d < _closest_dist) {
                 _closest_dist = _d;
                 _target = campfire;
                 _action_type = "campfire";
            }
        }
    }
}

// Set Active State
if (_target != noone) {
    active_interact_target = _target;
    var _key_name = global.get_key_name(global.key_interact);
    
    switch(_action_type) {
        case "stick": active_interact_msg = "[" + _key_name + "] " + MSG_TAKE_STICK; break;
        case "clue": active_interact_msg = "[" + _key_name + "] " + MSG_READ_CLUE; break;
        case "campfire": active_interact_msg = "[" + _key_name + "] " + MSG_ADD_FUEL; break;
    }
    
    // Execute Interaction

    if (keyboard_check_pressed(global.key_interact)) {
        switch(_action_type) {
            case "stick":
                stick_inventory++;
                instance_destroy(_target);
                break;
            case "clue":
                global.clues_collected++;
                instance_destroy(_target);
                if (global.clues_collected >= global.total_clues_needed) global.game_won = true;
                break;
            case "campfire":
                stick_inventory--;
                global.fuel += FUEL_PER_STICK;
                if (global.fuel > FUEL_MAX) global.fuel = FUEL_MAX;
                break;
        }
    }
}
