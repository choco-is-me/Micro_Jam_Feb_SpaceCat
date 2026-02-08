/// @description Render Tutorial UI

// Recalculate GUI scale if needed
if (gui_needs_recalc) {
    var _view_w = camera_get_view_width(view_camera[0]);
    gui_scale = display_get_gui_width() / _view_w;
    gui_needs_recalc = false;
}

// Get GUI dimensions
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _center_x = _gui_w / 2;
var _center_y = _gui_h / 2;

// === DRAW TUTORIAL SPRITES ===
// Calculate positions for 3 sprites in a row
var _spacing = TUTORIAL_SPRITE_SPACING;
var _sprite_scale = TUTORIAL_SPRITE_SCALE; // Use larger scale for visibility
var _sprite_y = _center_y - 30; // Shifted up for better centering

// Get sprite dimensions (including scale)
var _wasd_w = sprite_get_width(spr_wasd) * _sprite_scale;
var _wasd_h = sprite_get_height(spr_wasd) * _sprite_scale;
var _space_w = sprite_get_width(spr_spacebar) * _sprite_scale;
var _space_h = sprite_get_height(spr_spacebar) * _sprite_scale;
var _enter_w = sprite_get_width(spr_enter) * _sprite_scale;
var _enter_h = sprite_get_height(spr_enter) * _sprite_scale;

// Use the tallest sprite as baseline
var _max_height = max(_wasd_h, _space_h, _enter_h);

// WASD sprite (left) - compensate for top-left origin
var _wasd_x = _center_x - _spacing - _wasd_w / 2;
var _wasd_y = _sprite_y - _wasd_h / 2 + (_max_height - _wasd_h) / 2;
draw_sprite_ext(spr_wasd, 0, _wasd_x, _wasd_y, _sprite_scale, _sprite_scale, 0, c_white, 1);

// Spacebar sprite (center) - compensate for top-left origin
var _space_x = _center_x - _space_w / 2;
var _space_y = _sprite_y - _space_h / 2 + (_max_height - _space_h) / 2;
draw_sprite_ext(spr_spacebar, 0, _space_x, _space_y, _sprite_scale, _sprite_scale, 0, c_white, 1);

// Enter sprite (right) - compensate for top-left origin
var _enter_x = _center_x + _spacing - _enter_w / 2;
var _enter_y = _sprite_y - _enter_h / 2 + (_max_height - _enter_h) / 2;
draw_sprite_ext(spr_enter, 0, _enter_x, _enter_y, _sprite_scale, _sprite_scale, 0, c_white, 1);

// === DRAW DESCRIPTION TEXTS ===
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_font(FONT_MAIN);
draw_set_color(c_white);

var _text_y = _sprite_y + _max_height / 2 + TUTORIAL_TEXT_Y_OFFSET;

// WASD description (use centered x position)
var _wasd_text_x = _center_x - _spacing;
draw_text(_wasd_text_x, _text_y, TUTORIAL_MOVEMENT);

// Spacebar description (use centered x position)
draw_text(_center_x, _text_y, TUTORIAL_INTERACT);

// Enter description (use centered x position)
var _enter_text_x = _center_x + _spacing;
draw_text(_enter_text_x, _text_y, TUTORIAL_SUBMIT);

// === DRAW TITLE ===
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var _title_y = _center_y - 170;
draw_text(_center_x, _title_y, TUTORIAL_TITLE);

// === DRAW HELP HINT (Bottom) ===
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(c_white);
var _hint_y = _gui_h - 30;
draw_text(_center_x, _hint_y, TUTORIAL_HELP_HINT);

// === DRAW FADE OVERLAY ===
if (fade_alpha > 0) {
    draw_set_alpha(fade_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);
}

// === DRAW "STARTING" MESSAGE (After fade overlay, during dark linger only) ===
if (fade_state == "dark_linger") {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    
    // Draw only the typed portion of the message
    var _visible_text = string_copy(full_message, 1, floor(typed_chars));
    draw_text(_center_x, _center_y, _visible_text);
}

// Reset draw settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
