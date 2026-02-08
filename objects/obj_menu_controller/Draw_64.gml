/// @description Render Menu UI

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

// === DRAW TITLE ===
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(FONT_MAIN);
draw_set_color(c_white);

// === DRAW MENU OPTIONS ===
// Option 0: Start Game
var _start_y = _center_y + MENU_OPTION_START_Y_OFFSET;
var _start_color = (menu_index == 0) ? c_red : c_white; // Highlight selected in red (horror theme)
draw_set_color(_start_color);
draw_text(_center_x, _start_y, MENU_OPTION_START);

// Option 1: Exit Game
var _exit_y = _center_y + MENU_OPTION_EXIT_Y_OFFSET;
var _exit_color = (menu_index == 1) ? c_red : c_white;
draw_set_color(_exit_color);
draw_text(_center_x, _exit_y, MENU_OPTION_EXIT);

// === DRAW CURSOR (Horror pointer) ===
// Draw ">" symbol next to selected option
draw_set_color(c_red);
var _cursor_y = (menu_index == 0) ? _start_y : _exit_y;
var _cursor_x = _center_x + MENU_CURSOR_OFFSET_X;
draw_text(_cursor_x, _cursor_y, ">");

// === DRAW NAVIGATION HINT ===
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(c_white);
var _hint_y = _gui_h - MENU_NAV_HINT_Y_OFFSET;
draw_text(_center_x, _hint_y, MENU_NAV_HINT);

// === DRAW FADE OVERLAY ===
if (fade_alpha > 0) {
    draw_set_alpha(fade_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);
}

// Reset draw settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
