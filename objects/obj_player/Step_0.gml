if (global.game_over) exit;
if (global.game_won) exit;

// Update pickup sound cooldown
if (pickup_sound_cooldown > 0) {
    pickup_sound_cooldown -= global.dt;
}

var _hinput = keyboard_check(global.key_right) - keyboard_check(global.key_left);
var _vinput = keyboard_check(global.key_down) - keyboard_check(global.key_up);

var _is_moving = (_hinput != 0 || _vinput != 0);

if (_is_moving) {
    var _dir = point_direction(0, 0, _hinput, _vinput);
    var _move_amt = spd * global.dt;
    var _vx = lengthdir_x(_move_amt, _dir);
    var _vy = lengthdir_y(_move_amt, _dir);
    
    // Use collision script to slide against par_obstacle
    scr_move_and_collide(_vx, _vy, par_obstacle);
    
    // Update facing direction based on horizontal input
    if (_hinput != 0) {
        image_xscale = (_hinput > 0) ? 1 : -1; // Right = 1, Left = -1
    }
    
    // Switch to running animation
    if (sprite_index != spr_player_running) {
        sprite_index = spr_player_running;
        image_speed = 0; // Keep built-in animation disabled
        anim_frame = 0; // Reset animation frame
        anim_speed = PLAYER_RUN_ANIM_SPEED; // Use running speed
    }
    
    // Audio: Start running sound
    if (!audio_is_playing(running_sound_id)) {
        running_sound_id = audio_play_sound(snd_player_running, 3, true);
        audio_sound_gain(running_sound_id, RUNNING_SOUND_VOLUME, 0);
    }
} else {
    // Switch to idle animation
    if (sprite_index != spr_player_idle) {
        sprite_index = spr_player_idle;
        image_speed = 0; // Keep built-in animation disabled
        anim_frame = 0; // Reset animation frame
        anim_speed = PLAYER_IDLE_ANIM_SPEED; // Use idle speed
    }
    
    // Audio: Stop running sound
    if (audio_is_playing(running_sound_id)) {
        audio_stop_sound(running_sound_id);
        running_sound_id = -1;
    }
}

// Manual Animation Update (Delta Time Corrected)
var _num_frames = sprite_get_number(sprite_index);
if (_num_frames > 1) {
    anim_frame += anim_speed * global.dt;
    // Loop animation
    if (anim_frame >= _num_frames) {
        anim_frame = anim_frame mod _num_frames; // Wrap around
    }
    image_index = floor(anim_frame);
}

// Update Depth Sorting for 3D effect
scr_update_depth();

x = clamp(x, 0, room_width);

y = clamp(y, 0, room_height);

// Sanity
var campfire = instance_nearest(x, y, obj_campfire);

if (campfire != noone) {
    // Check if Player Bounding Box overlaps with Campfire Light Radius
    // Campfire Center (Visual) - Centered at flame/wood junction
    var _camp_cx = campfire.x;
    var _camp_cy = campfire.y - (campfire.sprite_height - CAMPFIRE_LIGHT_CENTER_OFFSET * campfire.image_yscale);
    
    // Check overlap: Returns >0 if any part of player bbox is in circle
    // If strict "whole body out" is needed for "Not Safe", then 
    // "Safe" = Any part is in. "Danger" = rectangle_in_circle == 0 (No Overlap)
    // If we want STRICT safety (whole body in), we check result == 1 (Inside).
    // Usually, "Touching light" = Safe is friendlier.
    
    var _in_light = rectangle_in_circle(bbox_left, bbox_top, bbox_right, bbox_bottom, _camp_cx, _camp_cy, campfire.light_radius);
    
    // DELTA TIME SANITY
    // Only gain sanity if fuel > 0 (campfire must be lit)
    if (_in_light > 0 && global.fuel > 0) {
         global.sanity += SANITY_REGAIN_LIGHT * global.dt;
         stand_timer = 0; // Reset stand timer if safe
    } else {
         // HORROR MECHANIC: Base sanity drain increases with clues collected
         // "The more you remember, the harder it is to escape the darkness"
         var _knowledge_multiplier = 1.0 + (global.clues_collected * 0.15); // +15% per clue
         
         global.sanity -= SANITY_DRAIN_DARK * global.dt * _knowledge_multiplier;
         
         // Check for Standing Still
         if (_hinput == 0 && _vinput == 0) {
             stand_timer += global.dt;
             // Active after X seconds - HARDCORE MODE
             if (stand_timer > TIME_BEFORE_STILL_PENALTY) {

                 global.sanity -= SANITY_DRAIN_STILL * global.dt * _knowledge_multiplier;
             }
         } else {
             stand_timer = 0;
         }
    }
}

global.sanity = clamp(global.sanity, 0, SANITY_MAX);
if (global.sanity <= 0) {
    global.game_over = true;
    
    // Start cinematic game over
    with (obj_controller) {
        if (ending_state == "none") {
            ending_state = "fade_out";
            ending_text_current = STR_GAME_OVER;
        }
    }
}


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

// 3. Check Campfire (Special handling - can have multiple simultaneous actions)
can_refuel_campfire = false;
can_submit_clues = false;
campfire_interact_msg = "";

if (campfire != noone) {
    // Campfire Origin = Bottom Center
    // Center of fire is at flame/wood junction
    var _camp_cx = campfire.x;
    var _camp_cy = campfire.y - (campfire.sprite_height - CAMPFIRE_LIGHT_CENTER_OFFSET * campfire.image_yscale);
    
    // Check overlap with Interaction Radius
    if (_check_overlap(_camp_cx, _camp_cy, CAMPFIRE_INTERACT_RADIUS)) {
        var _d = point_distance(x, y, _camp_cx, _camp_cy);
        
        // Check all possible campfire actions independently
        var _has_campfire_action = false;
        
        // Action 1: Refuel (if player has sticks and fuel not full)
        if (stick_inventory > 0 && global.fuel < FUEL_MAX) {
            can_refuel_campfire = true;
            _has_campfire_action = true;
        }
        
        // Action 2: Submit Clues (if player has minimum clues)
        if (global.clues_collected >= MIN_CLUES_TO_SUBMIT) {
            can_submit_clues = true;
            _has_campfire_action = true;
        }
        
        // Build campfire interaction message
        if (_has_campfire_action) {
            var _space_name = global.get_key_name(global.key_interact);
            var _enter_name = global.get_key_name(global.key_submit);
            
            var _lines = [];
            
            // Choose submit message based on completeness (subtle psychological cue)
            var _submit_msg = (global.clues_collected >= TOTAL_CLUES_NEEDED) ? MSG_SUBMIT_READY : MSG_SUBMIT_CLUES;
            
            if (can_refuel_campfire && can_submit_clues) {
                // Both actions available
                array_push(_lines, "[" + _space_name + "] " + MSG_CAMPFIRE_REFUEL);
                array_push(_lines, "[" + _enter_name + "] " + _submit_msg);
            } else if (can_refuel_campfire) {
                // Only refuel
                array_push(_lines, "[" + _space_name + "] " + MSG_CAMPFIRE_REFUEL);
            } else if (can_submit_clues) {
                // Only submit
                array_push(_lines, "[" + _enter_name + "] " + _submit_msg);
            }
            
            // Join lines
            campfire_interact_msg = "";
            for (var _i = 0; _i < array_length(_lines); _i++) {
                campfire_interact_msg += _lines[_i];
                if (_i < array_length(_lines) - 1) campfire_interact_msg += "\n";
            }
            
            // Set as active target (but don't add to normal action system)
            if (_d < _closest_dist) {
                _closest_dist = _d;
                _target = campfire;
                _action_type = "campfire_multi"; // Special marker
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
        case "campfire_multi": 
            // Use the pre-built campfire message
            active_interact_msg = campfire_interact_msg;
            break;
    }
    
    // Execute Interaction
    if (keyboard_check_pressed(global.key_interact)) {
        switch(_action_type) {
            case "stick":
                stick_inventory++;
                instance_destroy(_target);
                
                // Audio: Play pickup sound with cooldown
                if (pickup_sound_cooldown <= 0) {
                    audio_play_sound(snd_pickup_item, 5, false);
                    audio_sound_gain(snd_pickup_item, PICKUP_SOUND_VOLUME, 0);
                    pickup_sound_cooldown = PICKUP_SOUND_COOLDOWN;
                }
                break;
            case "clue":
                // Add clue dialog to queue
                ds_queue_enqueue(dialog_queue, _target.clue_text);
                
                global.clues_collected++;
                instance_destroy(_target);
                
                // Audio: Play pickup sound with cooldown
                if (pickup_sound_cooldown <= 0) {
                    audio_play_sound(snd_pickup_item, 5, false);
                    audio_sound_gain(snd_pickup_item, PICKUP_SOUND_VOLUME, 0);
                    pickup_sound_cooldown = PICKUP_SOUND_COOLDOWN;
                }
                break;
                
            case "campfire_multi":
                // Special case: Campfire has multiple actions on different keys
                // Refuel is handled here (SPACE key already consumed by this check)
                if (can_refuel_campfire) {
                    stick_inventory--;
                    global.fuel += FUEL_PER_STICK;
                    if (global.fuel > FUEL_MAX) global.fuel = FUEL_MAX;
                    
                    // Audio: Play refuel sound
                    audio_play_sound(snd_refuel, 4, false);
                    audio_sound_gain(snd_refuel, REFUEL_SOUND_VOLUME, 0);
                }
                break;
        }
    }
}

// --- CAMPFIRE SEPARATE ACTIONS (Independent key handling) ---
// Note: Refuel is now handled in the campfire_multi case above to avoid double keyboard_check_pressed

// Submit with ENTER key (uses separate key, so no conflict)
if (can_submit_clues && keyboard_check_pressed(global.key_submit)) {
    // Determine ending based on clues collected
    if (global.clues_collected >= TOTAL_CLUES_NEEDED) {
        global.ending_type = "true";
    } else {
        global.ending_type = "partial";
    }
    global.game_won = true;
    
    // Start cinematic ending in controller
    with (obj_controller) {
        ending_state = "fade_out";
        // Set appropriate ending text
        ending_text_current = (global.ending_type == "true") ? STR_GAME_WON_TRUE : STR_GAME_WON_PARTIAL;
    }
}

// --- DIALOG SYSTEM UPDATE ---
switch(dialog_state) {
    case "idle":
        // Check if there's a dialog in the queue
        if (!ds_queue_empty(dialog_queue)) {
            // Start new dialog
            dialog_current_text = ds_queue_dequeue(dialog_queue);
            dialog_visible_chars = 0;
            dialog_char_timer = 0;
            dialog_linger_timer = 0;
            dialog_alpha = 1.0;
            dialog_active = true;
            dialog_state = "typing";
        } else {
            dialog_active = false;
        }
        break;
        
    case "typing":
        // Typing animation
        dialog_char_timer += global.dt;
        var _chars_to_reveal = dialog_char_timer * DIALOG_CHARS_PER_SECOND;
        dialog_visible_chars = floor(_chars_to_reveal);
        
        // SKIP FEATURE: Press E key to instantly reveal full text
        if (keyboard_check_pressed(global.key_skip)) {
            dialog_visible_chars = string_length(dialog_current_text);
        }
        
        // Check if done typing
        if (dialog_visible_chars >= string_length(dialog_current_text)) {
            dialog_visible_chars = string_length(dialog_current_text);
            dialog_state = "lingering";
            dialog_linger_timer = 0;
        }
        break;
        
    case "lingering":
        // Show complete text for a duration
        dialog_linger_timer += global.dt;
        
        // SKIP FEATURE: Press E key to skip linger and advance to next dialog
        var _should_advance = (dialog_linger_timer >= DIALOG_LINGER_DURATION) || keyboard_check_pressed(global.key_skip);
        
        if (_should_advance) {
            // AUTO-ADVANCE: If there's a dialog in queue, start it immediately
            // Otherwise, fade out current dialog
            if (!ds_queue_empty(dialog_queue)) {
                dialog_state = "idle"; // Will trigger next dialog immediately
            } else {
                dialog_state = "fading";
            }
        }
        break;
        
    case "fading":
        // Fade out
        dialog_alpha -= DIALOG_FADE_SPEED * global.dt;
        if (dialog_alpha <= 0) {
            dialog_alpha = 0;
            dialog_state = "idle";
            dialog_active = false;
        }
        break;
}
