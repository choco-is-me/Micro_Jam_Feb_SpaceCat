if (global.game_over || global.game_won) exit;

if (global.fuel > 0) {
    global.fuel -= 0.05; // Fuel drain
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
            // 2% chance per frame to spawn
            if (random(100) < 2) {
                 // Spawn "a bit near" (200-350 pixels)
                 var dist = random_range(200, 350);
                 var dir = random(360);
                 var _x = obj_player.x + lengthdir_x(dist, dir);
                 var _y = obj_player.y + lengthdir_y(dist, dir);
                 
                 // Ensure spawn point is OUTSIDE the light radius
                 if (point_distance(_x, _y, campfire.x, campfire.y) > campfire.light_radius) {
                     instance_create_layer(_x, _y, "Instances", obj_enemy);
                 }
            }
        }
    }
}
