if (global.show_debug_grid) {
    draw_set_font(FONT_MAIN);
    draw_set_alpha(0.3);

    draw_set_color(c_white);
    
    var _grid_size = TILE_SIZE;

    var _w = room_width;
    var _h = room_height;
    
    // Draw Vertical Lines
    for (var i = 0; i < _w; i += _grid_size) {
        draw_line(i, 0, i, _h);
    }
    
    // Draw Horizontal Lines
    for (var j = 0; j < _h; j += _grid_size) {
        draw_line(0, j, _w, j);
    }
    
    draw_set_alpha(1);
    
    // Highlight occupied cells (Items) - Use Bbox for accuracy
    draw_set_color(c_yellow);
    with (obj_stick) {
        draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    }
    with (obj_clue) {
        draw_set_color(c_aqua);
        draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    }
}
