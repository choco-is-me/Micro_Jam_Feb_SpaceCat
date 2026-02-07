// CALCULATE DELTA TIME (Seconds passed)
global.dt = delta_time / 1000000;

if (global.game_over || global.game_won) exit;

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
    help_notif_alpha -= 1.0 * global.dt; // 1 second fade
}

if (global.fuel > 0) {
    global.fuel -= FUEL_DRAIN_RATE * global.dt; // Fuel drain per second
} else {
    global.fuel = 0;
}

// Enemy Spawning Logic
// Only 1 entity allowed.
if (instance_number(obj_enemy) == 0) {
    if (instance_exists(obj_player) && instance_exists(obj_campfire)) {
        var campfire = instance_nearest(obj_player.x, obj_player.y, obj_campfire);
        var dist_to_fire = point_distance(obj_player.x, obj_player.y, campfire.x, campfire.y);
        
        // Spawn only if player is OUTSIDE the safe zone
        if (dist_to_fire > campfire.light_radius) {
            
            // Increment Timer
            enemy_spawn_timer += global.dt;
            
            // Check Timer > Interval
            if (enemy_spawn_timer > ENEMY_SPAWN_INTERVAL) {
                 
                 // Chance check (simulate randomness still, or just force spawn?)
                 // Let's force spawn to be reliable if interval passed, or add randomness to interval.
                 // Reset timer
                 enemy_spawn_timer = 0;
                 
                 // SPAWN LOGIC: Randomly spawn just outside camera view
                 var cam = view_camera[0];
                 var cx = camera_get_view_x(cam);
                 var cy = camera_get_view_y(cam);
                 var cw = camera_get_view_width(cam);
                 var ch = camera_get_view_height(cam);
                 var margin = 50; // Distance from edge
                 
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
                 
                 // Ensure spawn point is OUTSIDE the light radius
                 if (point_distance(_x, _y, campfire.x, campfire.y) > campfire.light_radius) {
                     instance_create_layer(_x, _y, "Instances", obj_enemy);
                 }
            }
        }
    }
}
