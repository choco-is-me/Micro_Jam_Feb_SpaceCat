// Draw Player Sprite
draw_self();

// Draw Personal Light/Sense Radius (Centered on Body)
// Use Bounding Box center if possible for better accuracy, fallback to sprite height
// (bbox_top + bbox_bottom) / 2 gives the vertical center of the COLLISION MASK.
// If your mask is just the feet, this might be too low.
// Let's stick to sprite_height logic but ensure it accounts for scale if we ever scale the player.

var _sprite_h = sprite_height; // This includes image_yscale automatically
var _cx = x;
var _cy = y - (_sprite_h / 2);

draw_set_color(c_white);
draw_set_alpha(0.15); // Lower alpha for subtlety
draw_circle(_cx, _cy, PLAYER_LIGHT_RADIUS, false);
draw_set_alpha(1);

// Draw "Watched" Eyes Effect
if (is_being_watched) {
    var _num_frames = sprite_get_number(spr_ue_eye);
    
    // Check if we are holding the stare
    if (eye_anim_pause_timer > 0) {
        eye_anim_pause_timer -= global.dt;
    } else {
        // Animation Logic
        var _spd = eye_anim_speed / 60;
        eye_anim_frame += _spd * eye_anim_dir;
        
        // Bounds Check
        if (eye_anim_frame >= _num_frames - 1) {
            // Hit max frame: Pause and Reverse
            eye_anim_frame = _num_frames - 1;
            eye_anim_pause_timer = eye_anim_pause_duration;
            eye_anim_dir = -1;
        } else if (eye_anim_frame <= 0) {
            // Hit min frame: Reverse immediately
            eye_anim_frame = 0;
            eye_anim_dir = 1;
        }
    }
    
    // Draw above player
    // Origin is Bottom Center, so X is center.
    // Y needs to be above head. Head is at (y - sprite_height).
    var _eyes_x = x;
    var _eyes_y = y - sprite_height - 10; // 10px padding
    
    draw_sprite(spr_ue_eye, eye_anim_frame, _eyes_x, _eyes_y);
}

