// Draw GUI elements on GUI layer for crisp text
draw_set_font(FONT_MAIN);

var _cam = view_camera[0];
var _cx = camera_get_view_x(_cam);
var _cy = camera_get_view_y(_cam);
var _cw = camera_get_view_width(_cam);
var _ch = camera_get_view_height(_cam);

// Convert Player position to GUI coordinates
var _player_vx = (x - _cx) / _cw;
var _player_vy = ((y - 30) - _cy) / _ch;
var _guix = _player_vx * display_get_gui_width();
var _guiy = _player_vy * display_get_gui_height();

// --- DIALOG SYSTEM (PRIORITY 1) ---
// Hide dialog during ending cinematics to prevent overlap with ending text
var _show_dialog = (dialog_active && dialog_state != "idle");
if (instance_exists(obj_controller) && obj_controller.ending_state != "none") {
    _show_dialog = false;
}

if (_show_dialog) {
    // Dynamic width based on camera size (75% of camera width)
    var _dialog_max_w = display_get_gui_width() * DIALOG_WIDTH_PERCENT;
    
    // Get visible portion of text
    var _visible_text = string_copy(dialog_current_text, 1, dialog_visible_chars);
    
    // Calculate line height for max row constraints
    var _line_height = string_height("M"); // Height of single line
    var _max_text_height = _line_height * DIALOG_MAX_ROWS;
    
    // Calculate text dimensions with word wrap
    var _text_w = _dialog_max_w - DIALOG_BG_PADDING * 2;
    var _text_h = string_height_ext(_visible_text, _line_height, _text_w);
    
    // Clamp height to max rows
    if (_text_h > _max_text_height) {
        _text_h = _max_text_height;
    }
    
    // Position above player head
    var _dialog_x = _guix;
    var _dialog_y = _guiy + DIALOG_Y_OFFSET;
    
    // Draw background box with alpha
    draw_set_alpha(dialog_alpha * 0.8);
    draw_set_color(c_black);
    var _box_w = _text_w + DIALOG_BG_PADDING * 2;
    var _box_h = _text_h + DIALOG_BG_PADDING * 2;
    draw_roundrect(_dialog_x - _box_w/2, _dialog_y - _box_h, 
                   _dialog_x + _box_w/2, _dialog_y, false);
    
    // Draw text with alpha (with line separation)
    draw_set_alpha(dialog_alpha);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_text_ext(_dialog_x, _dialog_y - DIALOG_BG_PADDING, _visible_text, _line_height, _text_w);
    
    // Draw skip hint during typing and lingering
    if (dialog_state == "typing" || dialog_state == "lingering") {
        draw_set_alpha(dialog_alpha * 0.6);
        draw_set_color(c_yellow);
        draw_set_valign(fa_top);
        var _skip_key = global.get_key_name(global.key_skip);
        draw_text(_dialog_x, _dialog_y + 5, MSG_DIALOG_SKIP_PREFIX + _skip_key + MSG_DIALOG_SKIP_SUFFIX);
    }
    
    // Reset alpha
    draw_set_alpha(1.0);
    
    // Draw queue indicator if there are pending dialogs
    if (!ds_queue_empty(dialog_queue)) {
        var _queue_count = ds_queue_size(dialog_queue);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_color(c_yellow);
        draw_text(_dialog_x, _dialog_y + 35, "(" + string(_queue_count) + " more memory" + (_queue_count > 1 ? "ies" : "y") + " waiting...)");
    }
}

// --- INTERACTION PROMPT (PRIORITY 2) ---
// Only show if dialog is NOT active AND not in ending cinematic
if (active_interact_target != noone && !dialog_active) {
    // Don't show during ending cinematics
    var _show_prompt = true;
    if (instance_exists(obj_controller) && obj_controller.ending_state != "none") {
        _show_prompt = false;
    }
    
    if (_show_prompt) {
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        draw_set_color(c_white);
        draw_text(_guix, _guiy, active_interact_msg);
    }
}

// Reset draw settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
