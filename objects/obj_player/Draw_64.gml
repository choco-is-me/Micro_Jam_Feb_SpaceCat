// Draw Interaction Prompt on GUI layer for crisp text
if (active_interact_target != noone) {
    draw_set_font(FONT_MAIN);
    
    var _cam = view_camera[0];

    var _cx = camera_get_view_x(_cam);
    var _cy = camera_get_view_y(_cam);
    var _cw = camera_get_view_width(_cam);
    var _ch = camera_get_view_height(_cam);
    
    // Check if player is actually inside the view (optimization)
    // Though usually player is centered, so yes.
    
    // Convert World (x, y) to Viewport Ration (0.0 - 1.0)
    // Player head offset is roughly y - 30
    var _vx = (x - _cx) / _cw;
    var _vy = ((y - 30) - _cy) / _ch;
    
    // Convert Ratio to GUI Coordinates
    var _guix = _vx * display_get_gui_width();
    var _guiy = _vy * display_get_gui_height();
    
    // Draw Text
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_white);
    draw_text(_guix, _guiy, active_interact_msg);
    
    // Reset
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
