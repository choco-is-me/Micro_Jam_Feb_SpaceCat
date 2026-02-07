draw_set_font(FONT_MAIN);
draw_set_color(c_white);

// Determine dynamic line height based on font
var _lh = string_height("M");
var _margin = 20;

draw_text(20, _margin, UI_LABEL_SANITY + string(floor(global.sanity)) + "%");
draw_text(20, _margin + _lh, UI_LABEL_FUEL + string(floor(global.fuel)) + "%");
draw_text(20, _margin + _lh * 2, UI_LABEL_CLUES + string(global.clues_collected) + UI_SEPARATOR + string(global.total_clues_needed));
draw_text(20, _margin + _lh * 3, UI_LABEL_STICKS + string(obj_player.stick_inventory) + UI_SEPARATOR + string(obj_player.max_sticks));

// --- CONTROLS UI ---

var _gui_w = display_get_gui_width();
draw_set_halign(fa_right);

if (help_open) {
    // Dynamic background box
    var _pad = 15;
    
    // 1. Define instructions
    var _t1 = UI_CTRL_TITLE;
    var _t2 = UI_CTRL_MOVE;
    var _t3 = UI_CTRL_INTERACT_PREFIX + global.get_key_name(global.key_interact);
    var _t4 = UI_CTRL_GRID;
    var _t5 = UI_CTRL_CLOSE;
    
    // 2. Calculate dimensions based on *actual* text size

    var _max_w = max(
        string_width(_t1), 
        string_width(_t2), 
        string_width(_t3), 
        string_width(_t4), 
        string_width(_t5)
    );
    
    var _box_w = _max_w + (_pad * 2);
    var _lines_count = 5;
    var _box_h = (_pad * 2) + (_lines_count * _lh);
    
    var _box_top = 20;
    var _box_right = _gui_w - 20;
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
    draw_text(_text_x, _text_y, _t5);
    
} else if (help_notif_alpha > 0) {
    draw_set_alpha(min(1, help_notif_alpha));
    draw_set_color(c_yellow);
    draw_text(_gui_w - 20, 20, UI_NOTIF_OPEN_HELP);
    draw_set_alpha(1);
}

draw_set_halign(fa_left);

if (global.game_over) {
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

if (global.game_won) {
    var _txt = STR_GAME_WON;
    
    // Dynamic Scaling: Text should take up ~20% of the screen height
    var _target_h = display_get_gui_height() * 0.20;
    var _current_h = string_height(_txt);
    var _scale = _target_h / _current_h;
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_lime);
    draw_text_transformed(display_get_gui_width()/2, display_get_gui_height()/2, _txt, _scale, _scale, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}


