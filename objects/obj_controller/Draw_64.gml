draw_set_font(FONT_MAIN);
draw_set_color(c_white);

// Determine dynamic line height based on font
var _lh = string_height("M");
var _margin = 20;

    // --- SANITY BAR ---
    // Position: Center Top
    // Sprite: spr__sanity_bar (21 frames: 0=High/100%, 20=Low/0%)
    
    // Calculate UI scale to match game pixel density
    // The GUI layer is set to window size (hires), while the game is lowres (480x270)
    var _view_w = camera_get_view_width(view_camera[0]);
    var _scale = display_get_gui_width() / _view_w;
    
    var _sanity_norm = clamp(global.sanity / SANITY_MAX, 0, 1);
    var _bar_frame = round((1 - _sanity_norm) * 20);
    
    // var _gui_w = display_get_gui_width(); // Already defined below or can be reused. 
    // Wait, _gui_w is defined at line 87 (in original code it was late).
    // Let's define it once at the top if needed, or remove 'var' here if it's reused.
    // Looking at the flow: _gui_w is used here for the bar.
    
    // Redeclaration fix: Use a unique name or define strictly once.
    // Let's use assignment only if it was already defined, but it hasn't been defined YET in this scope.
    // The warning said line 87. In this file, the FIRST declaration is around line 21. 
    // And the SECOND declaration is around line 87.
    
    var _gui_w = display_get_gui_width();
    var _bar_w = sprite_get_width(spr__sanity_bar) * _scale;
    var _bar_x = (_gui_w / 2) - (_bar_w / 2);
    var _bar_y = 20; // Slight top margin
    
    draw_sprite_ext(spr__sanity_bar, _bar_frame, _bar_x, _bar_y, _scale, _scale, 0, c_white, 1);

    // Removed text debug sanity count
    
    // --- FUEL & INVENTORY UI ---
    
    // 1. Fuel (Text)
    // draw_text(20, _margin + _lh, UI_LABEL_FUEL + string(floor(global.fuel)) + "%");
    // Actually, let's just push it down a bit or keep it. User didn't ask to change fuel representation, just sticks/clues.
    // But for consistency let's keep fuel as text at top left for now.
    draw_text(20, _margin, UI_LABEL_FUEL + string(floor(global.fuel)) + "%"); // Moved up to replace sanity text slot
    
    var _icon_size = 32 * _scale;
    var _x_pos = 20;
    var _y_pos_start = _margin + _lh * 1.5; // Start below fuel
    
    // 2. Clues (Sprite + Count)
    // Only show if near campfire (player within CAMPFIRE_INTERACT_RADIUS of obj_campfire)
    
    var _show_clues = false;
    if (instance_exists(obj_player) && instance_exists(obj_campfire)) {
         var _dist = point_distance(obj_player.x, obj_player.y, obj_campfire.x, obj_campfire.y);
         if (_dist < CAMPFIRE_INTERACT_RADIUS) {
             _show_clues = true;
         }
    }

    if (_show_clues) {
        var _clue_y = _y_pos_start;
        draw_sprite_ext(spr_clue_note, 0, _x_pos, _clue_y, _scale, _scale, 0, c_white, 1);
        
        draw_set_valign(fa_middle);
        // Only show collected count, hide total needed to keep player guessing
        var _text_clue = string(global.clues_collected);
        draw_text(_x_pos + _icon_size + 10, _clue_y + (_icon_size / 2), _text_clue);
    }
    
    // 3. Sticks (Sprite + Count)
    // Sticks always visible? Or also hidden? Usually inventory is visible. Let's keep sticks visible.
    // Adjust Y position based on whether clues were shown? 
    // Actually, consistency might be better if sticks stay in place.
    // But if we hide clues, there's a gap.
    // Let's shift sticks up if clues are hidden.
    
    var _stick_y = _y_pos_start;
    if (_show_clues) {
        _stick_y += _icon_size + 10;
    }

    draw_sprite_ext(spr_stick, 0, _x_pos, _stick_y, _scale, _scale, 0, c_white, 1);
    
    var _text_stick = string(obj_player.stick_inventory) + " / " + string(obj_player.max_sticks);
    draw_text(_x_pos + _icon_size + 10, _stick_y + (_icon_size / 2), _text_stick);
    
    draw_set_valign(fa_top); // Reset

    // Removed old text lines
    // draw_text(20, _margin + _lh, UI_LABEL_FUEL + string(floor(global.fuel)) + "%");
    // draw_text(20, _margin + _lh * 2, UI_LABEL_CLUES + ...
    // draw_text(20, _margin + _lh * 3, UI_LABEL_STICKS + ...

// --- CONTROLS UI ---

// _gui_w was already defined above for the sanity bar. Remove 'var'.
_gui_w = display_get_gui_width();
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
    
    // Reuse _scale variable (remove 'var')
    _current_h = string_height(_txt);
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
    
    // Reuse _scale variable (remove 'var')
    _target_h = display_get_gui_height() * 0.20;
    var _current_h = string_height(_txt);
    var _scale = _target_h / _current_h;
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_lime);
    draw_text_transformed(display_get_gui_width()/2, display_get_gui_height()/2, _txt, _scale, _scale, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}


