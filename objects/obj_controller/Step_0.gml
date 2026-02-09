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
        // GUARANTEED SPAWN: Try multiple positions until one works
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
            
            var _spawn_x = 0;
            var _spawn_y = 0;
            var _found_valid_position = false;
            
            // Try all 4 sides in random order
            var _sides = [0, 1, 2, 3]; // 0=Top, 1=Right, 2=Bottom, 3=Left
            // Shuffle array
            for (var i = 3; i > 0; i--) {
                var j = irandom(i);
                var temp = _sides[i];
                _sides[i] = _sides[j];
                _sides[j] = temp;
            }
            
            // Try each side up to 3 times
            for (var s = 0; s < 4 && !_found_valid_position; s++) {
                for (var attempt = 0; attempt < 3 && !_found_valid_position; attempt++) {
                    var spawn_side = _sides[s];
                    
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
                    var _outside_light = true;
                    if (global.fuel > 0) {
                        _outside_light = point_distance(_spawn_x, _spawn_y, _camp_cx, _camp_cy) > (_campfire.light_radius + CAMERA_SPAWN_SAFETY_MARGIN);
                    }
                    
                    var _dist_to_player = point_distance(_spawn_x, _spawn_y, obj_player.x, obj_player.y);
                    
                    // More lenient checks: only require outside light and 80px+ from player
                    if (_outside_light && _dist_to_player > 80) {
                        _found_valid_position = true;
                    }
                }
            }
            
            // FALLBACK: If all attempts failed, spawn at farthest screen corner from player
            if (!_found_valid_position) {
                var _corners = [
                    [cx, cy], // Top-left
                    [cx + cw, cy], // Top-right
                    [cx + cw, cy + ch], // Bottom-right
                    [cx, cy + ch] // Bottom-left
                ];
                
                var _max_dist = 0;
                var _best_corner = 0;
                
                for (var c = 0; c < 4; c++) {
                    var _d = point_distance(_corners[c][0], _corners[c][1], obj_player.x, obj_player.y);
                    if (_d > _max_dist) {
                        _max_dist = _d;
                        _best_corner = c;
                    }
                }
                
                // Spawn slightly off-screen from best corner
                _spawn_x = _corners[_best_corner][0] + ((_best_corner == 1 || _best_corner == 2) ? margin : -margin);
                _spawn_y = _corners[_best_corner][1] + ((_best_corner == 2 || _best_corner == 3) ? margin : -margin);
            }
            
            // ALWAYS spawn enemy once warning completes
            instance_create_layer(_spawn_x, _spawn_y, "Instances", obj_enemy);
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

// Audio Management: Campfire Sound (Distance-Based Volume)
// Start campfire sound when fuel > 0, stop when fuel depletes
if (global.fuel > 0) {
    if (!audio_is_playing(campfire_sound_id)) {
        campfire_sound_id = audio_play_sound(snd_campfire, 1, true);
        audio_sound_gain(campfire_sound_id, CAMPFIRE_SOUND_VOLUME_MAX, 0);
    }
    
    // Dynamic volume based on player distance from campfire
    if (instance_exists(obj_player) && instance_exists(obj_campfire)) {
        var _campfire = instance_find(obj_campfire, 0);
        var _camp_cx = _campfire.x;
        var _camp_cy = _campfire.y - (_campfire.sprite_height - CAMPFIRE_LIGHT_CENTER_OFFSET * _campfire.image_yscale);
        
        var _dist_to_campfire = point_distance(obj_player.x, obj_player.y, _camp_cx, _camp_cy);
        
        // Calculate volume: close = max, far = min
        var _volume_factor = clamp(1 - (_dist_to_campfire / CAMPFIRE_SOUND_DISTANCE_MAX), 0, 1);
        var _target_volume = lerp(CAMPFIRE_SOUND_VOLUME_MIN, CAMPFIRE_SOUND_VOLUME_MAX, _volume_factor);
        
        // Smoothly adjust volume (fade over 100ms for smooth transitions)
        audio_sound_gain(campfire_sound_id, _target_volume, 100);
    }
} else {
    if (audio_is_playing(campfire_sound_id)) {
        audio_stop_sound(campfire_sound_id);
        campfire_sound_id = -1;
    }
}

// Audio Management: Heartbeat Sound
// Play when sanity is at or below threshold (35% = frame 13 of sanity bar)
var _sanity_norm = global.sanity / SANITY_MAX;
if (_sanity_norm <= SANITY_HEARTBEAT_THRESHOLD) {
    if (!audio_is_playing(heartbeat_sound_id)) {
        heartbeat_sound_id = audio_play_sound(snd_heartbeat, 2, true);
        audio_sound_gain(heartbeat_sound_id, HEARTBEAT_SOUND_VOLUME, 0);
    }
} else {
    if (audio_is_playing(heartbeat_sound_id)) {
        audio_stop_sound(heartbeat_sound_id);
        heartbeat_sound_id = -1;
    }
}

// Enemy Spawning Logic - Distance-Based Spawn Rate
// Only spawn if no warning is active AND no enemy exists (chasing OR frozen)
// STRICT RULE: Only 1 enemy at a time for balanced gameplay
var _can_spawn = !enemy_warning_active && !instance_exists(obj_enemy);

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
