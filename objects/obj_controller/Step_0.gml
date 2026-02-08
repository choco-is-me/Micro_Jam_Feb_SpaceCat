// CALCULATE DELTA TIME (Seconds passed)
global.dt = delta_time / 1000000;

// ROOM START FADE-IN (from tutorial)
if (room_start_fade) {
    room_fade_alpha -= MENU_FADE_SPEED * global.dt;
    if (room_fade_alpha <= 0) {
        room_fade_alpha = 0;
        room_start_fade = false; // Fade complete, resume normal gameplay
    }
    // Don't process game logic during fade-in
    exit;
}

// ENDING CINEMATIC SYSTEM (Runs even when game_won/game_over is true)
switch(ending_state) {
    case "fade_out":
        // Close help menu when ending starts
        help_open = false;
        
        // Fade to black
        ending_fade_alpha += ENDING_FADE_SPEED * global.dt;
        if (ending_fade_alpha >= 1) {
            ending_fade_alpha = 1;
            // Start typing ending text (already set when state was triggered)
            ending_text_visible_chars = 0;
            ending_text_timer = 0;
            ending_state = "typing";
        }
        break;
        
    case "typing":
        // Type out ending text character by character
        ending_text_timer += global.dt;
        ending_text_visible_chars = floor(ending_text_timer * ENDING_TEXT_CHARS_PER_SECOND);
        
        // Skip with E key
        if (keyboard_check_pressed(global.key_skip)) {
            ending_text_visible_chars = string_length(ending_text_current);
        }
        
        // Check if done typing
        if (ending_text_visible_chars >= string_length(ending_text_current)) {
            ending_text_visible_chars = string_length(ending_text_current);
            ending_linger_timer = 0;
            ending_state = "linger";
        }
        break;
        
    case "linger":
        // Show complete text for a duration
        ending_linger_timer += global.dt;
        
        // Skip with E key
        if (keyboard_check_pressed(global.key_skip) || ending_linger_timer >= ENDING_TEXT_LINGER) {
            // Different prompts for different endings
            if (global.game_over || global.ending_type == "partial") {
                ending_state = "prompt"; // Show restart prompt for game over or partial ending
            } else {
                ending_state = "thankyou"; // Show thank you screen for true ending
            }
            ending_linger_timer = 0;
        }
        break;
        
    case "prompt":
        // Show restart prompt (for both partial ending and game over)
        if (keyboard_check_pressed(global.key_restart)) {
            game_restart();
        }
        break;
        
    case "thankyou":
        // True ending: Type out thank you message
        ending_text_timer += global.dt;
        ending_text_visible_chars = floor(ending_text_timer * ENDING_TEXT_CHARS_PER_SECOND);
        
        var _thankyou_text = STR_THANK_YOU;
        if (ending_text_visible_chars >= string_length(_thankyou_text)) {
            ending_text_visible_chars = string_length(_thankyou_text);
            ending_linger_timer = 0;
            ending_state = "thankyou_wait";
        }
        break;
        
    case "thankyou_wait":
        // Wait for any key to quit
        if (keyboard_check_pressed(vk_anykey)) {
            game_end();
        }
        break;
}

// Don't run normal game logic during ending
if (global.game_over || global.game_won) exit;

// --- ENEMY WARNING SYSTEM ---
// Handle pre-spawn warning cycle
if (enemy_warning_active) {
    // Check if player reached campfire light (escape condition)
    if (instance_exists(obj_player) && instance_exists(obj_campfire)) {
        var _campfire = instance_find(obj_campfire, 0);
        var _camp_cx = _campfire.x;
        var _camp_cy = _campfire.y - (_campfire.sprite_height - CAMPFIRE_LIGHT_CENTER_OFFSET * _campfire.image_yscale);
        
        var _player_in_light = rectangle_in_circle(
            obj_player.bbox_left, obj_player.bbox_top,
            obj_player.bbox_right, obj_player.bbox_bottom,
            _camp_cx, _camp_cy, _campfire.light_radius
        );
        
        // Player is safe only if in light AND campfire has fuel
        if (_player_in_light > 0 && global.fuel > 0) {
            // Player reached safety! Cancel warning
            enemy_warning_active = false;
            enemy_warning_has_opened = false;
            eye_anim_frame = 0;
            eye_anim_dir = 1;
            eye_anim_pause_timer = 0;
        }
    }
    
    // Track if eye animation completed a full cycle
    // Eye opens (frame 0->5) then closes (5->0)
    if (eye_anim_frame >= sprite_get_number(spr_ue_eye) - 1) {
        enemy_warning_has_opened = true; // Eye fully opened
    }
    
    if (enemy_warning_has_opened && eye_anim_frame <= 0.5 && eye_anim_dir == 1) {
        // Eye closed again and is moving forward = cycle complete
        // Recalculate spawn position based on CURRENT camera view (player moved during warning)
        if (instance_exists(obj_campfire) && instance_exists(obj_player)) {
            var _campfire = instance_find(obj_campfire, 0);
            var _camp_cx = _campfire.x;
            var _camp_cy = _campfire.y - (_campfire.sprite_height - CAMPFIRE_LIGHT_CENTER_OFFSET * _campfire.image_yscale);
            
            // Get current camera position
            var cam = view_camera[0];
            var cx = camera_get_view_x(cam);
            var cy = camera_get_view_y(cam);
            var cw = camera_get_view_width(cam);
            var ch = camera_get_view_height(cam);
            var margin = CAMERA_SPAWN_MARGIN;
            
            // Recalculate spawn position outside current view
            var spawn_side = irandom(3); // 0=Top, 1=Right, 2=Bottom, 3=Left
            var _spawn_x, _spawn_y;
            
            switch(spawn_side) {
                case 0: // Top
                   _spawn_x = random_range(cx, cx + cw);
                   _spawn_y = cy - margin;
                   break;
                case 1: // Right
                   _spawn_x = cx + cw + margin;
                   _spawn_y = random_range(cy, cy + ch);
                   break;
                case 2: // Bottom
                   _spawn_x = random_range(cx, cx + cw);
                   _spawn_y = cy + ch + margin;
                   break;
                case 3: // Left
                   _spawn_x = cx - margin;
                   _spawn_y = random_range(cy, cy + ch);
                   break;
            }
            
            // Validate spawn position
            var _valid_position = false;
            
            // Check 1: Outside light radius (or campfire has no fuel)
            var _outside_light = true;
            if (global.fuel > 0) {
                // Only check light radius if campfire is lit
                _outside_light = point_distance(_spawn_x, _spawn_y, _camp_cx, _camp_cy) > (_campfire.light_radius + CAMERA_SPAWN_SAFETY_MARGIN);
            }
            
            if (_outside_light) {
                // Check 2: Not too close to player (minimum distance)
                var _dist_to_player = point_distance(_spawn_x, _spawn_y, obj_player.x, obj_player.y);
                if (_dist_to_player > 100) { // Minimum 100px from player
                    // Check 3: No collision with objects
                    if (scr_is_spawn_position_valid(_spawn_x, _spawn_y, SPAWN_COLLISION_CHECK_RADIUS)) {
                        _valid_position = true;
                    }
                }
            }
            
            // Only spawn if position is valid
            if (_valid_position) {
                instance_create_layer(_spawn_x, _spawn_y, "Instances", obj_enemy);
            }
        }
        
        // Reset warning state
        enemy_warning_active = false;
        enemy_warning_has_opened = false;
    }
}

// Controls / Debug
if (keyboard_check_pressed(vk_f1)) {
    help_open = !help_open;
    if (help_open) help_notif_alpha = 0; 
}

if (keyboard_check_pressed(vk_f2)) {
    global.show_debug_grid = !global.show_debug_grid;
}

// Fade out notification
if (help_notif_alpha > 0 && !help_open) {
    help_notif_alpha -= UI_HELP_FADE_SPEED * global.dt;
}

if (global.fuel > 0) {
    global.fuel -= FUEL_DRAIN_RATE * global.dt; // Fuel drain per second
} else {
    global.fuel = 0;
}

// Enemy Spawning Logic - Distance-Based Spawn Rate
// Only spawn if no warning is active AND no actively chasing enemy exists
// Allow spawning even if a frozen enemy exists (they're not threatening)
var _can_spawn = !enemy_warning_active;
if (instance_exists(obj_enemy)) {
    var _enemy = instance_find(obj_enemy, 0);
    if (_enemy.state == "chasing") {
        _can_spawn = false; // Prevent spawn only while enemy is actively chasing
    }
}

if (_can_spawn) {
    if (instance_exists(obj_player) && instance_exists(obj_campfire)) {
        var campfire = instance_nearest(obj_player.x, obj_player.y, obj_campfire);
        
        // Calculate distance from player to campfire center
        var _camp_cx = campfire.x;
        var _camp_cy = campfire.y - (campfire.sprite_height - CAMPFIRE_LIGHT_CENTER_OFFSET * campfire.image_yscale);
        
        var _dist_to_camp = point_distance(obj_player.x, obj_player.y, _camp_cx, _camp_cy);
        
        // Calculate spawn chance based on distance
        // BUT only if campfire has fuel - depleted campfire provides no distance benefit
        var _spawn_chance = ENEMY_SPAWN_BASE_CHANCE;
        
        if (global.fuel > 0) {
            // Campfire is lit - distance matters
            if (_dist_to_camp > ENEMY_SPAWN_DISTANCE_MIN) {
                // Interpolate between base and max chance
                var _t = clamp((_dist_to_camp - ENEMY_SPAWN_DISTANCE_MIN) / (ENEMY_SPAWN_DISTANCE_MAX - ENEMY_SPAWN_DISTANCE_MIN), 0, 1);
                _spawn_chance = lerp(ENEMY_SPAWN_BASE_CHANCE, ENEMY_SPAWN_MAX_CHANCE, _t);
            }
        } else {
            // Campfire is depleted - always use max spawn chance (no safe zone)
            _spawn_chance = ENEMY_SPAWN_MAX_CHANCE;
        }
        
        // HORROR MECHANIC: Increase spawn rate based on clues collected
        // The more truth you uncover, the stronger the entity becomes
        var _clue_multiplier = 1.0 + (global.clues_collected * 0.2); // +20% per clue
        _spawn_chance *= _clue_multiplier;
        
        // Roll for spawn
        if (random(1) < _spawn_chance) {
            // SPAWN LOGIC: Randomly spawn just outside camera view
            var cam = view_camera[0];
            var cx = camera_get_view_x(cam);
            var cy = camera_get_view_y(cam);
            var cw = camera_get_view_width(cam);
            var ch = camera_get_view_height(cam);
            var margin = CAMERA_SPAWN_MARGIN;
            
            var spawn_side = irandom(3); // 0=Top, 1=Right, 2=Bottom, 3=Left
            var _x, _y;
            
            switch(spawn_side) {
                case 0: // Top
                   _x = random_range(cx, cx + cw);
                   _y = cy - margin;
                   break;
                case 1: // Right
                   _x = cx + cw + margin;
                   _y = random_range(cy, cy + ch);
                   break;
                case 2: // Bottom
                   _x = random_range(cx, cx + cw);
                   _y = cy + ch + margin;
                   break;
                case 3: // Left
                   _x = cx - margin;
                   _y = random_range(cy, cy + ch);
                   break;
            }
            
            // Ensure spawn point is OUTSIDE the light radius AND not colliding with objects
            // If campfire has no fuel, light check is skipped
            var _can_trigger_warning = true;
            
            if (global.fuel > 0) {
                // Only check light radius if campfire is lit
                _can_trigger_warning = point_distance(_x, _y, _camp_cx, _camp_cy) > (campfire.light_radius + CAMERA_SPAWN_SAFETY_MARGIN);
            }
            
            if (_can_trigger_warning) {
                // Check for collision with existing objects before spawning
                if (scr_is_spawn_position_valid(_x, _y, SPAWN_COLLISION_CHECK_RADIUS)) {
                    // Instead of spawning immediately, trigger warning
                    enemy_warning_active = true;
                    enemy_warning_has_opened = false;
                    // Reset eye animation for warning cycle
                    eye_anim_frame = 0;
                    eye_anim_dir = 1;
                    eye_anim_pause_timer = 0;
                }
            }
        }
    }
}
