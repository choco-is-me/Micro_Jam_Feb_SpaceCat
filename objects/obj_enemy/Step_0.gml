if (global.game_over || global.game_won) exit;
if (!instance_exists(obj_player)) exit;

// State: Frozen (after attacking player)
if (state == "frozen") {
    // Switch to idle animation
    if (sprite_index != spr_ue_idle) {
        sprite_index = spr_ue_idle;
        image_speed = 0; // Keep built-in animation disabled
        anim_frame = 0;
        anim_speed = ENEMY_IDLE_ANIM_SPEED; // Use idle speed
    }
    
    // Count down freeze timer
    freeze_timer -= global.dt;
    
    if (freeze_timer <= 0) {
        // Despawn after freeze duration
        instance_destroy();
    }
    
    // Manual Animation Update (Delta Time Corrected)
    var _num_frames = sprite_get_number(sprite_index);
    if (_num_frames > 1) {
        anim_frame += anim_speed * global.dt;
        if (anim_frame >= _num_frames) {
            anim_frame = anim_frame mod _num_frames;
        }
        image_index = floor(anim_frame);
    }
    
    exit; // Skip all other logic while frozen
}

// State: Chasing
if (state == "chasing") {
    // Switch to running animation
    if (sprite_index != spr_ue_running) {
        sprite_index = spr_ue_running;
        image_speed = 0; // Keep built-in animation disabled
        anim_frame = 0;
        anim_speed = ENEMY_RUN_ANIM_SPEED; // Use running speed
    }
    
    // DESPAWN Logic: Check if Entity touches light OR Player is safe
    // Only if campfire has fuel (light is active)
    if (instance_exists(obj_campfire) && global.fuel > 0) {
        var campfire = instance_nearest(x, y, obj_campfire);
        
        // Campfire Center (flame/wood junction)
        var _camp_cx = campfire.x;
        var _camp_cy = campfire.y - (campfire.sprite_height - CAMPFIRE_LIGHT_CENTER_OFFSET * campfire.image_yscale);
        
        // 1. Check Player Safety (Using precise bbox check like in obj_player)
        var _p_safe = rectangle_in_circle(obj_player.bbox_left, obj_player.bbox_top, obj_player.bbox_right, obj_player.bbox_bottom, _camp_cx, _camp_cy, campfire.light_radius);
        
        // 2. Check Entity Vulnerability (If Entity touches light, it burns)
        var _e_burn = rectangle_in_circle(bbox_left, bbox_top, bbox_right, bbox_bottom, _camp_cx, _camp_cy, campfire.light_radius);
        
        // Instead of instant despawn, freeze and stare at player before disappearing
        if (_p_safe > 0 || _e_burn > 0) {
            state = "frozen";
            freeze_timer = ENEMY_FREEZE_DURATION;
            sprite_index = spr_ue_idle;
            image_speed = 0; // Disable built-in animation
            anim_frame = 0; // Reset animation frame
            anim_speed = ENEMY_IDLE_ANIM_SPEED; // Set idle animation speed
            exit; // Exit to frozen state immediately
        }
    }

    // Chase Logic
    var dir = point_direction(x, y, obj_player.x, obj_player.y);
    var move_amt = spd * global.dt;
    
    var _vx = lengthdir_x(move_amt, dir);
    var _vy = lengthdir_y(move_amt, dir);
    
    // Update facing direction based on horizontal movement
    if (_vx != 0) {
        image_xscale = (_vx > 0) ? 1 : -1; // Right = 1, Left = -1
    }
    
    // Collision-aware movement
    scr_move_and_collide(_vx, _vy, par_obstacle);
    
    // Manual Animation Update (Delta Time Corrected)
    var _num_frames = sprite_get_number(sprite_index);
    if (_num_frames > 1) {
        anim_frame += anim_speed * global.dt;
        if (anim_frame >= _num_frames) {
            anim_frame = anim_frame mod _num_frames;
        }
        image_index = floor(anim_frame);
    }
    
    // Update Depth
    scr_update_depth();
    
    // Attack Logic
    if (place_meeting(x, y, obj_player)) {
        global.sanity -= ENEMY_DAMAGE_SANITY;
        
        // Enter frozen state instead of immediate despawn
        state = "frozen";
        freeze_timer = ENEMY_FREEZE_DURATION;
        sprite_index = spr_ue_idle;
        image_speed = 0; // Disable built-in animation
        anim_frame = 0; // Reset animation frame
        anim_speed = ENEMY_IDLE_ANIM_SPEED; // Set idle animation speed
    }
}
