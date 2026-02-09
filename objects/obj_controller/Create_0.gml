randomize();
global.sanity = SANITY_MAX;
global.fuel = FUEL_MAX;
global.max_fuel = FUEL_MAX;
global.clues_collected = 0;
global.total_clues_needed = TOTAL_CLUES_NEEDED;
global.game_over = false;
global.game_won = false;
global.ending_type = ""; // "true", "partial", or ""

// Room Start Fade-In (from tutorial)
room_start_fade = true; // Start with fade-in effect
room_fade_alpha = 1; // Start at full black

// Ending Cinematic System
ending_state = "none"; // "fade_out", "typing", "linger", "prompt", "thankyou", "thankyou_wait"
ending_fade_alpha = 0; // 0 = normal game, 1 = full black
ending_text_current = "";
ending_text_visible_chars = 0;
ending_text_timer = 0;
ending_linger_timer = 0;
global.message = "";
global.show_debug_grid = false; // Toggle for grid visualization

// Eye Animation (UI Warning when enemy exists)
eye_anim_frame = 0;
eye_anim_dir = 1; // 1 for forward, -1 for backward
eye_anim_speed = PLAYER_EYE_ANIM_SPEED;
eye_anim_pause_timer = 0;
eye_anim_pause_duration = PLAYER_EYE_PAUSE_DURATION;

// Enemy Warning System (Pre-spawn warning)
enemy_warning_active = false;
enemy_warning_has_opened = false; // Track if eye reached frame 5 (fully open)

// --- INPUT MAPPING SYSTEM ---
global.key_interact = vk_space;
global.key_submit = vk_enter; // Separate key for submitting clues
global.key_skip = ord("E"); // Skip dialog/advance text
global.key_restart = ord("R"); // Restart game (partial ending)
global.key_up = ord("W");
global.key_left = ord("A");
global.key_down = ord("S");
global.key_right = ord("D");


global.get_key_name = function(_key) {
    switch(_key) {
        case vk_space: return "SPACE";
        case vk_enter: return "ENTER";
        case vk_shift: return "SHIFT";
        case vk_control: return "CTRL";
        case vk_alt: return "ALT";
        case vk_up: return "UP";
        case vk_down: return "DOWN";
        case vk_left: return "LEFT";
        case vk_right: return "RIGHT";
        case vk_escape: return "ESC";
        case vk_backspace: return "BACK";
        case vk_tab: return "TAB";
        default: return chr(_key);
    }
};

// Help UI State
help_open = false;
help_notif_alpha = 3.5; // Start >1 so it lingers before fading

// GUI Performance Cache (calculated once, reused every frame)
gui_scale = 0;
gui_width = 0;
gui_icon_size = 0;
gui_margin = UI_MARGIN;
gui_needs_recalc = true; // Recalculate on first draw

// --- DYNAMIC SPAWN SYSTEM ---
// 1. Ensure Campfire Exists (Use existing or spawn at center default)
if (!instance_exists(obj_campfire)) {
    instance_create_layer(room_width/2, room_height/2, "Instances", obj_campfire);
}
var _camp = instance_find(obj_campfire, 0);
var _cx = _camp.x;
var _cy = _camp.y;

// 2. Ensure Player Exists (Use existing or spawn near campfire)
if (!instance_exists(obj_player)) {
    instance_create_layer(_cx, _cy + 60, "Instances", obj_player);
}
var _player = instance_find(obj_player, 0);

// 3. Create Camera (Snap to player initially)
if (!instance_exists(obj_camera)) {
    instance_create_layer(_player.x, _player.y, "Instances", obj_camera);
}

// --- RESOURCE GENERATION ---
var occupied_cells = ds_list_create(); // Track used cells to prevent overlap

// Initialize Delta Time global
global.dt = 0;

// Audio Management
campfire_sound_id = -1; // ID for campfire ambient loop
heartbeat_sound_id = -1; // ID for low sanity heartbeat loop

// Start campfire sound if fuel > 0
if (global.fuel > 0) {
    campfire_sound_id = audio_play_sound(snd_campfire, 1, true);
    audio_sound_gain(campfire_sound_id, CAMPFIRE_SOUND_VOLUME_MAX, 0);
}

var spawn_resource = function(_obj, _count, _min_dist, _max_dist, _list, _grid_size, _center_x, _center_y) {

    var _spawned_count = 0;
    var _attempts = 0;
    
    while (_spawned_count < _count && _attempts < 2000) {
        _attempts++;
        
        // 1. Pick a random grid coordinate
        var _gx = irandom(room_width div _grid_size);
        var _gy = irandom(room_height div _grid_size);
        
        // 2. Create unique key for this cell (e.g., "10_5")
        var _key = string(_gx) + "_" + string(_gy);
        
        // 3. Convert to world coordinates
        // Spawning Logic for Bottom-Center Origin Objects
        // X: Center of tile (16px offset from tile left)
        // Y: Center of tile (16px offset from tile top) - Centers items in grid cell
        var _xx = (_gx * _grid_size) + (_grid_size / 2);
        var _yy = (_gy * _grid_size) + (_grid_size / 2);
        
        // 4. Check if position is not too close to room edges
        var _within_bounds = (_xx >= SPAWN_EDGE_MARGIN && _xx <= room_width - SPAWN_EDGE_MARGIN &&
                               _yy >= SPAWN_EDGE_MARGIN && _yy <= room_height - SPAWN_EDGE_MARGIN);
        
        if (!_within_bounds) continue; // Skip this position if too close to edge
        
        // 5. Check Distance Rules (Relative to passed center now)
        var _dist_to_center = point_distance(_center_x, _center_y, _xx, _yy);
        
        if (_dist_to_center >= _min_dist && _dist_to_center <= _max_dist) {
            
            // 6. Check if cell is empty
            if (ds_list_find_index(_list, _key) == -1) {
                
                // 7. Check for collision with existing objects
                if (scr_is_spawn_position_valid(_xx, _yy, SPAWN_COLLISION_CHECK_RADIUS)) {
                    
                    // Success! Spawn and Mark cell
                    instance_create_layer(_xx, _yy, "Instances", _obj);
                    ds_list_add(_list, _key);
                    _spawned_count++;
                }
            }
        }
    }
};

// Spawn parameters relative to Campfire Position
// Use a large max radius (e.g. half the room width roughly, or hard 1000px)
var _spawn_radius_max = max(room_width, room_height) / 2;

// Spawn Sticks (Inner Ring)
spawn_resource(obj_stick, 15, 200, _spawn_radius_max * 0.8, occupied_cells, TILE_SIZE, _cx, _cy);

// Spawn Clues (Outer Ring) - UNIQUE SPAWN SYSTEM
// Create shuffled array of clue IDs (1-7) to ensure each spawns exactly once
var _clue_ids = [1, 2, 3, 4, 5, 6, 7];
// Shuffle the array
for (var _i = array_length(_clue_ids) - 1; _i > 0; _i--) {
    var _j = irandom(_i);
    var _temp = _clue_ids[_i];
    _clue_ids[_i] = _clue_ids[_j];
    _clue_ids[_j] = _temp;
}

// Spawn each unique clue
var _clue_spawned = 0;
var _clue_attempts = 0;

while (_clue_spawned < TOTAL_CLUES_NEEDED && _clue_attempts < 2000) {
    _clue_attempts++;
    
    // 1. Pick a random grid coordinate
    var _gx = irandom(room_width div TILE_SIZE);
    var _gy = irandom(room_height div TILE_SIZE);
    
    // 2. Create unique key for this cell
    var _key = string(_gx) + "_" + string(_gy);
    
    // 3. Convert to world coordinates
    var _xx = (_gx * TILE_SIZE) + (TILE_SIZE / 2);
    var _yy = (_gy * TILE_SIZE) + (TILE_SIZE / 2);
    
    // 4. Check if position is not too close to room edges
    var _within_bounds = (_xx >= SPAWN_EDGE_MARGIN && _xx <= room_width - SPAWN_EDGE_MARGIN &&
                           _yy >= SPAWN_EDGE_MARGIN && _yy <= room_height - SPAWN_EDGE_MARGIN);
    
    if (!_within_bounds) continue; // Skip this position if too close to edge
    
    // 5. Check Distance Rules (Outer Ring)
    var _dist_to_center = point_distance(_cx, _cy, _xx, _yy);
    
    if (_dist_to_center >= 250 && _dist_to_center <= _spawn_radius_max) {
        
        // 6. Check if cell is empty
        if (ds_list_find_index(occupied_cells, _key) == -1) {
            
            // 7. Check for collision with existing objects
            if (scr_is_spawn_position_valid(_xx, _yy, SPAWN_COLLISION_CHECK_RADIUS)) {
                
                // Success! Create clue with unique ID
                var _new_clue = instance_create_layer(_xx, _yy, "Instances", obj_clue);
                _new_clue.clue_id = _clue_ids[_clue_spawned];
                
                // Initialize sprite and text based on assigned clue_id
                _new_clue.initialize_clue();
                
                ds_list_add(occupied_cells, _key);
                _clue_spawned++;
            }
        }
    }
}

ds_list_destroy(occupied_cells);

// --- SHADER SYSTEM INITIALIZATION ---
// Surface for shader application
shader_surface = -1;

// Shader uniform handles (cached for performance)
if (SHADER_ENABLED && shader_is_compiled(shd_lighting)) {
    uni_resolution = shader_get_uniform(shd_lighting, "u_resolution");
    uni_ambient = shader_get_uniform(shd_lighting, "u_ambient");
    uni_vignette = shader_get_uniform(shd_lighting, "u_vignette");
    uni_num_lights = shader_get_uniform(shd_lighting, "u_num_lights");
    uni_light_positions = shader_get_uniform(shd_lighting, "u_light_positions");
    uni_light_colors = shader_get_uniform(shd_lighting, "u_light_colors");
    uni_light_radii = shader_get_uniform(shd_lighting, "u_light_radii");
    uni_light_intensities = shader_get_uniform(shd_lighting, "u_light_intensities");
} else {
    // Shader not available - disable it
    if (SHADER_ENABLED) {
        show_debug_message("WARNING: Shader shd_lighting not compiled or not available - shader disabled");
    }
}
