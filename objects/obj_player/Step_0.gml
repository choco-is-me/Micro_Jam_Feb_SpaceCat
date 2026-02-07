if (global.game_over || global.game_won) exit;

var hinput = keyboard_check(global.key_right) - keyboard_check(global.key_left);
var vinput = keyboard_check(global.key_down) - keyboard_check(global.key_up);

if (hinput != 0 || vinput != 0) {
    var dir = point_direction(0, 0, hinput, vinput);
    x += lengthdir_x(spd, dir);
    y += lengthdir_y(spd, dir);
}

x = clamp(x, 0, room_width);
y = clamp(y, 0, room_height);

// Sanity
var campfire = instance_nearest(x, y, obj_campfire);
if (campfire != noone) {
    var dist = point_distance(x, y, campfire.x, campfire.y);
    var effective_radius = (global.fuel > 0) ? campfire.light_radius : 0;
    
    // Assuming 60 FPS
    if (dist < effective_radius) {
        // Inside Campfire Radius: +2% per second -> +2/60 per frame
         global.sanity += 2/60;
         stand_timer = 0; // Reset stand timer if safe
    } else {
        // Outside Campfire Radius: -1% per second -> -1/60 per frame
         global.sanity -= 1/60;
         
         // Check for Standing Still
         if (hinput == 0 && vinput == 0) {
             stand_timer++;
             // Active after 1 second (1 * 60 = 60 frames) - HARDCORE MODE
             if (stand_timer > 60) {
                 // penalty: -2% per second -> -2/60 per frame
                 global.sanity -= 2/60;
             }
         } else {
             stand_timer = 0;
         }
    }
}

global.sanity = clamp(global.sanity, 0, 100);
if (global.sanity <= 0) global.game_over = true;

// --- INTERACTION SYSTEM ---
active_interact_target = noone;
active_interact_msg = "";

var _interact_range = 40;
var _closest_dist = 9999;
var _target = noone;
var _action_type = ""; // "stick", "campfire", "clue"

// 1. Check Stick
var _stick = instance_nearest(x, y, obj_stick);
if (_stick != noone) {
    var _d = point_distance(x, y, _stick.x, _stick.y);
    if (_d < _interact_range && _d < _closest_dist) {
         if (stick_inventory < max_sticks) {
            _closest_dist = _d;
            _target = _stick;
            _action_type = "stick";
         }
    }
}

// 2. Check Clue
var _clue = instance_nearest(x, y, obj_clue);
if (_clue != noone) {
    var _d = point_distance(x, y, _clue.x, _clue.y);
    if (_d < _interact_range && _d < _closest_dist) {
        _closest_dist = _d;
        _target = _clue;
        _action_type = "clue";
    }
}

// 3. Check Campfire
if (campfire != noone) {
    var _d = point_distance(x, y, campfire.x, campfire.y);
    // Larger range for campfire for ease of use
    if (_d < 100) {
        // Only prioritize if we have sticks or it's simply the closest thing
        if (stick_inventory > 0 && global.fuel < 100) {
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
        case "stick": active_interact_msg = "[" + _key_name + "] Take Stick"; break;
        case "clue": active_interact_msg = "[" + _key_name + "] Read Clue"; break;
        case "campfire": active_interact_msg = "[" + _key_name + "] Add Fuel"; break;
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
                global.fuel += 20;
                if (global.fuel > 100) global.fuel = 100;
                break;
        }
    }
}
