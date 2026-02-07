randomize();
global.sanity = SANITY_MAX;
global.fuel = FUEL_MAX;
global.max_fuel = FUEL_MAX;
global.clues_collected = 0;
global.total_clues_needed = TOTAL_CLUES_NEEDED;
global.game_over = false;
global.game_won = false;
global.message = "";
global.show_debug_grid = false; // Toggle for grid visualization

// --- INPUT MAPPING SYSTEM ---
global.key_interact = vk_space;
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
enemy_spawn_timer = 0;

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
        
        // 3. Convert to world coordinates (Center of tile)
        var _xx = (_gx * _grid_size) + (_grid_size / 2);
        var _yy = (_gy * _grid_size) + (_grid_size / 2);
        
        // 4. Check Distance Rules (Relative to passed center now)
        var _dist_to_center = point_distance(_center_x, _center_y, _xx, _yy);
        
        if (_dist_to_center >= _min_dist && _dist_to_center <= _max_dist) {
            
            // 5. Check if cell is empty
            if (ds_list_find_index(_list, _key) == -1) {
                
                // Success! Spawn and Mark cell
                instance_create_layer(_xx, _yy, "Instances", _obj);
                ds_list_add(_list, _key);
                _spawned_count++;
            }
        }
    }
};

// Spawn parameters relative to Campfire Position
// Use a large max radius (e.g. half the room width roughly, or hard 1000px)
var _spawn_radius_max = max(room_width, room_height) / 2;

// Spawn Sticks (Inner Ring)
spawn_resource(obj_stick, 15, 200, _spawn_radius_max * 0.8, occupied_cells, TILE_SIZE, _cx, _cy);

// Spawn Clues (Outer Ring)
spawn_resource(obj_clue, TOTAL_CLUES_NEEDED, 250, _spawn_radius_max, occupied_cells, TILE_SIZE, _cx, _cy);

ds_list_destroy(occupied_cells);

