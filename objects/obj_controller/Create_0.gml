randomize();
global.sanity = 100;
global.fuel = 100;
global.max_fuel = 100;
global.clues_collected = 0;
global.total_clues_needed = 5;
global.game_over = false;
global.game_won = false;
global.message = "";
global.show_debug_grid = false; // Toggle for grid visualization

// --- INPUT MAPPING SYSTEM ---
global.key_interact = ord("E");
global.key_up = ord("W");
global.key_left = ord("A");
global.key_down = ord("S");
global.key_right = ord("D");

global.get_key_name = function(_key) {
    // Basic ASCII return. 
    // You can expand this with a switch statement for VK_SPACE, VK_ENTER etc. if needed later.
    return chr(_key);
};

// Help UI State
help_open = false;
help_notif_alpha = 3.5; // Start >1 so it lingers before fading

// Spawn Center Objects if they don't exist
if (!instance_exists(obj_campfire)) {
    instance_create_layer(room_width/2, room_height/2, "Instances", obj_campfire);
}
if (!instance_exists(obj_player)) {
    instance_create_layer(room_width/2, room_height/2 + 60, "Instances", obj_player);
}
// Create Camera
if (!instance_exists(obj_camera)) {
    instance_create_layer(0, 0, "Instances", obj_camera);
}

// --- GRID SPAWN SYSTEM ---
var GRID_SIZE = 32;
var occupied_cells = ds_list_create(); // Track used cells to prevent overlap

var spawn_resource = function(_obj, _count, _min_dist, _max_dist, _list, _grid_size) {
    var _spawned_count = 0;
    var _attempts = 0;
    
    while (_spawned_count < _count && _attempts < 1000) {
        _attempts++;
        
        // 1. Pick a random grid coordinate
        var _gx = irandom(room_width div _grid_size);
        var _gy = irandom(room_height div _grid_size);
        
        // 2. Create unique key for this cell (e.g., "10_5")
        var _key = string(_gx) + "_" + string(_gy);
        
        // 3. Convert to world coordinates (Center of tile)
        var _xx = (_gx * _grid_size) + (_grid_size / 2);
        var _yy = (_gy * _grid_size) + (_grid_size / 2);
        
        // 4. Check Distance Rules
        var _dist_to_center = point_distance(room_width/2, room_height/2, _xx, _yy);
        
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

// Spawn Sticks (Inner/Middle Ring)
spawn_resource(obj_stick, 15, 200, room_width/2 - 50, occupied_cells, GRID_SIZE);

// Spawn Clues (Middle/Outer Ring)
spawn_resource(obj_clue, 5, 250, room_width/2 - 20, occupied_cells, GRID_SIZE);

ds_list_destroy(occupied_cells);
