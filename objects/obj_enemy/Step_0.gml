if (global.game_over || global.game_won) exit;
if (instance_exists(obj_player)) {
    
    // DESPAWN Logic: Check if Entity touches light OR Player is safe
    if (instance_exists(obj_campfire)) {
        var campfire = instance_nearest(x, y, obj_campfire);
        
        // Check Player distance to light
        var p_dist_to_fire = point_distance(obj_player.x, obj_player.y, campfire.x, campfire.y);
        
        // Check Entity self distance to light
        var e_dist_to_fire = point_distance(x, y, campfire.x, campfire.y);
        
        // Despawn if Player is safe OR Entity stepped into light
        if (p_dist_to_fire < campfire.light_radius || e_dist_to_fire < (campfire.light_radius + 10)) {
            instance_destroy();
            exit;
        }
    }

    // Chase Logic
    move_towards_point(obj_player.x, obj_player.y, spd);
    
    // Attack Logic
    var dist = point_distance(x, y, obj_player.x, obj_player.y);
    if (dist < 20) {
        global.sanity -= 30;
        instance_destroy();
    }
}
