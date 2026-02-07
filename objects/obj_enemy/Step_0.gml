if (global.game_over || global.game_won) exit;
if (instance_exists(obj_player)) {
    
    // DESPAWN Logic: Check if Entity touches light OR Player is safe
    if (instance_exists(obj_campfire)) {
        var campfire = instance_nearest(x, y, obj_campfire);
        
        // Campfire Center
        var _camp_cx = campfire.x;
        var _camp_cy = campfire.y - (campfire.sprite_height / 2);
        
        // 1. Check Player Safety (Using precise bbox check like in obj_player)
        var _p_safe = rectangle_in_circle(obj_player.bbox_left, obj_player.bbox_top, obj_player.bbox_right, obj_player.bbox_bottom, _camp_cx, _camp_cy, campfire.light_radius);
        
        // 2. Check Entity Vulnerability (If Entity touches light, it burns)
        var _e_burn = rectangle_in_circle(bbox_left, bbox_top, bbox_right, bbox_bottom, _camp_cx, _camp_cy, campfire.light_radius);
        
        // Despawn if Player is sufficiently safe OR Entity stepped into light
        if (_p_safe > 0 || _e_burn > 0) {
            instance_destroy();
            exit;
        }
    }

    // Chase Logic
    // Manual Movement for Delta Time support
    var dir = point_direction(x, y, obj_player.x, obj_player.y);
    var move_amt = spd * global.dt;
    
    var _vx = lengthdir_x(move_amt, dir);
    var _vy = lengthdir_y(move_amt, dir);
    
    // Collision-aware movement
    scr_move_and_collide(_vx, _vy, par_obstacle);
    
    // Update Depth
    scr_update_depth();
    
    // Attack Logic
    // Use true collision check
    if (place_meeting(x, y, obj_player)) {
        global.sanity -= ENEMY_DAMAGE_SANITY;
        instance_destroy();
    }
}
