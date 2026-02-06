draw_set_color(c_white);
draw_text(20, 20, "Sanity: " + string(floor(global.sanity)) + "%");
draw_text(20, 40, "Fuel: " + string(floor(global.fuel)) + "%");
draw_text(20, 60, "Clues: " + string(global.clues_collected) + " / " + string(global.total_clues_needed));
draw_text(20, 80, "Sticks: " + string(obj_player.stick_inventory) + " / " + string(obj_player.max_sticks));

if (global.game_over) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_red);
    draw_text_transformed(display_get_gui_width()/2, display_get_gui_height()/2, "GAME OVER\nSanity Depleted or Lost in Dark", 3, 3, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

if (global.game_won) {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_lime);
    draw_text_transformed(display_get_gui_width()/2, display_get_gui_height()/2, "THE TRUTH IS REVEALED\nThe Entity was your own guilt.", 2, 2, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
