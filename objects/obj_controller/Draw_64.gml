draw_set_font(FONT_MAIN);
draw_set_color(c_white);

// Calculate GUI scale once (or when window resizes)
if (gui_needs_recalc) {
    var _view_w = camera_get_view_width(view_camera[0]);
    gui_scale = display_get_gui_width() / _view_w;
    gui_width = display_get_gui_width();
    gui_icon_size = UI_ICON_SIZE_BASE * gui_scale;
    gui_needs_recalc = false;
}

// Determine dynamic line height based on font
var _lh = string_height("M");

// --- SANITY BAR ---
// Position: Center Top
// Sprite: spr__sanity_bar (21 frames: 0=High/100%, 20=Low/0%)

var _sanity_norm = clamp(global.sanity / SANITY_MAX, 0, 1);
var _bar_frame = round((1 - _sanity_norm) * 20);

var _bar_w = sprite_get_width(spr__sanity_bar) * gui_scale;
var _bar_x = (gui_width / 2) - (_bar_w / 2);
var _bar_y = gui_margin; // Use config margin

draw_sprite_ext(spr__sanity_bar, _bar_frame, _bar_x, _bar_y, gui_scale, gui_scale, 0, c_white, 1);

// --- ENEMY WARNING EYES (Top-Left) ---
// Show ONLY during warning phase (before enemy spawns), not after enemy exists
var _enemy_exists = instance_exists(obj_enemy);
var _show_warning = enemy_warning_active && ending_state == "none";

if (_show_warning) {
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
        
        // Draw eyes at top-left
        // Sprite has center origin (width 61px, origin at x=30), so offset to prevent clipping
        var _eye_sprite_w = sprite_get_width(spr_ue_eye) * gui_scale;
        var _eye_x = gui_margin + (_eye_sprite_w / 2); // Offset by half width to account for center origin
        var _eye_y = gui_margin;
        draw_sprite_ext(spr_ue_eye, floor(eye_anim_frame), _eye_x, _eye_y, gui_scale, gui_scale, 0, c_white, 1);
    } else {
        // Reset animation when no enemy and no warning
        if (!enemy_warning_active) {
            eye_anim_frame = 0;
            eye_anim_dir = 1;
            eye_anim_pause_timer = 0;
        }
    }

    // --- INVENTORY UI ---
    // Hide during ending cinematics
if (ending_state == "none") {
    
var _ui_left_margin = gui_margin;

// Fix X Pos: Ensure sprite isn't clipped
var _x_pos = _ui_left_margin + (gui_icon_size / 2);

// Start below eye warning (if visible) or at margin
var _y_pos_start = gui_margin + (_show_warning ? (sprite_get_height(spr_ue_eye) * gui_scale + 10) : 0) + (gui_icon_size / 2);
    // Only show if near campfire (player within CAMPFIRE_INTERACT_RADIUS of obj_campfire)
    // Use consistent campfire center position (visual center, not sprite origin)
    var _show_clues = false;
    if (instance_exists(obj_player) && instance_exists(obj_campfire)) {
         var _campfire = instance_find(obj_campfire, 0);
         var _camp_cx = _campfire.x;
         var _camp_cy = _campfire.y - (_campfire.sprite_height - CAMPFIRE_LIGHT_CENTER_OFFSET * _campfire.image_yscale);
         var _dist = point_distance(obj_player.x, obj_player.y, _camp_cx, _camp_cy);
         if (_dist < CAMPFIRE_INTERACT_RADIUS) {
             _show_clues = true;
         }
    }

    if (_show_clues) {
        var _clue_y = _y_pos_start;
        // Both sprites have center origin (origin:4) so draw at same Y as text
        draw_sprite_ext(spr_clue_note, 0, _x_pos, _clue_y, gui_scale, gui_scale, 0, c_white, 1);
    
    draw_set_valign(fa_middle);
    var _text_clue = string(global.clues_collected);
    // Text aligned to same Y coordinate as sprite center
    draw_text(_x_pos + (gui_icon_size / 2) + 10, _clue_y, _text_clue);
}

// 2. Sticks (Sprite + Count)

var _stick_y = _y_pos_start;
if (_show_clues) {
    _stick_y += gui_icon_size + 10;
}

// Stick Sprite - center origin, draw at same Y as text
draw_sprite_ext(spr_stick, 0, _x_pos, _stick_y, gui_scale, gui_scale, 0, c_white, 1);

draw_set_valign(fa_middle);
var _text_stick = string(obj_player.stick_inventory) + " / " + string(obj_player.max_sticks);

// Stick Text - vertically centered to match sprite
draw_text(_x_pos + (gui_icon_size / 2) + 10, _stick_y, _text_stick);

draw_set_valign(fa_top); // Reset

} // End inventory UI check

// --- CONTROLS UI ---
// Hide during ending cinematics

draw_set_halign(fa_right);

if (help_open && ending_state == "none") {
    // Dynamic background box
    var _pad = UI_PADDING;
    
    // 1. Define instructions
    var _t1 = UI_CTRL_TITLE;
    var _t2 = UI_CTRL_MOVE;
    var _t3 = UI_CTRL_INTERACT_PREFIX + global.get_key_name(global.key_interact);
    var _t4 = UI_CTRL_SUBMIT_PREFIX + global.get_key_name(global.key_submit);
    var _t5 = UI_CTRL_SKIP_PREFIX + global.get_key_name(global.key_skip);
    var _t6 = UI_CTRL_GRID;
    var _t7 = UI_CTRL_CLOSE;
    
    // 2. Calculate dimensions based on *actual* text size

    var _max_w = max(
        string_width(_t1), 
        string_width(_t2), 
        string_width(_t3), 
        string_width(_t4), 
        string_width(_t5),
        string_width(_t6),
        string_width(_t7)
    );
    
    var _box_w = _max_w + (_pad * 2);
    var _lines_count = 7; // Updated for skip key line
    var _box_h = (_pad * 2) + (_lines_count * _lh);
    
    var _box_top = 20;
    var _box_right = gui_width - 20;
    var _box_left = _box_right - _box_w;
    
    // Draw Box
    draw_set_color(c_black);
    draw_set_alpha(0.8);
    draw_rectangle(_box_left, _box_top, _box_right, _box_top + _box_h, false);
    draw_set_alpha(1);
    
    // Draw Text
    draw_set_color(c_white);
    var _text_y = _box_top + _pad;
    var _text_x = _box_right - _pad;
    
    draw_text(_text_x, _text_y, _t1); _text_y += _lh;
    draw_text(_text_x, _text_y, _t2); _text_y += _lh;
    draw_text(_text_x, _text_y, _t3); _text_y += _lh;
    draw_text(_text_x, _text_y, _t4); _text_y += _lh;
    draw_text(_text_x, _text_y, _t5); _text_y += _lh;
    draw_text(_text_x, _text_y, _t6); _text_y += _lh;
    draw_text(_text_x, _text_y, _t7);
    
} else if (help_notif_alpha > 0 && ending_state == "none") {
    draw_set_alpha(min(1, help_notif_alpha));
    draw_set_color(c_yellow);
    draw_text(gui_width - 20, 20, UI_NOTIF_OPEN_HELP);
    draw_set_alpha(1);
}

draw_set_halign(fa_left);

// --- CINEMATIC ENDING SYSTEM ---
// Draw black fade overlay
if (ending_fade_alpha > 0) {
    draw_set_alpha(ending_fade_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
}

// --- ROOM START FADE-IN (from tutorial) ---
// Draw black fade overlay during room start
if (room_fade_alpha > 0) {
    draw_set_alpha(room_fade_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
}

// Draw ending text on black screen
if (ending_state == "typing" || ending_state == "linger" || ending_state == "prompt") {
    var _visible_text = string_copy(ending_text_current, 1, ending_text_visible_chars);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    // ALL endings use blood red for horror atmosphere
    draw_set_color(make_color_rgb(204, 0, 0)); // Blood red
    
    // Draw ending text higher up to avoid overlap
    var _gui_center_x = display_get_gui_width() / 2;
    var _gui_center_y = display_get_gui_height() / 2;
    draw_text(_gui_center_x, _gui_center_y - 100, _visible_text);
    
    // Draw skip hint during typing (lower position)
    if (ending_state == "typing") {
        draw_set_alpha(0.5);
        draw_set_color(c_gray);
        var _skip_key = global.get_key_name(global.key_skip);
        draw_text(_gui_center_x, _gui_center_y + 150, "[Press " + _skip_key + " to skip]");
        draw_set_alpha(1);
    }
    
    // Draw restart prompt for partial ending or game over (in blood red)
    if (ending_state == "prompt") {
        draw_set_color(make_color_rgb(204, 0, 0)); // Blood red
        var _restart_key = global.get_key_name(global.key_restart);
        
        if (global.game_over) {
            draw_text(_gui_center_x, _gui_center_y + 150, "Press [" + _restart_key + "] to try again");
        } else {
            draw_text(_gui_center_x, _gui_center_y + 150, STR_PLAY_AGAIN);
        }
    }
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Draw thank you screen for true ending
if (ending_state == "thankyou" || ending_state == "thankyou_wait") {
    var _thankyou_text = STR_THANK_YOU;
    var _visible_thankyou = string_copy(_thankyou_text, 1, ending_text_visible_chars);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(204, 0, 0)); // Blood red for consistency
    
    var _gui_center_x = display_get_gui_width() / 2;
    var _gui_center_y = display_get_gui_height() / 2;
    draw_text(_gui_center_x, _gui_center_y, _visible_thankyou);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// Old system: Simple game over
if (global.game_over && ending_state == "none") {
    var _txt = STR_GAME_OVER;
    
    // Dynamic Scaling: Text should take up ~25% of the screen height regardless of font size
    var _target_h = display_get_gui_height() * 0.25; 
    var _current_h = string_height(_txt);
    var _scale = _target_h / _current_h;
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_red);
    draw_text_transformed(display_get_gui_width()/2, display_get_gui_height()/2, _txt, _scale, _scale, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}


