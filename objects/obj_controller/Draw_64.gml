draw_set_color(c_white);
draw_text(20, 20, "Sanity: " + string(floor(global.sanity)) + "%");
draw_text(20, 40, "Fuel: " + string(floor(global.fuel)) + "%");
draw_text(20, 60, "Clues: " + string(global.clues_collected) + " / " + string(global.total_clues_needed));
draw_text(20, 80, "Sticks: " + string(obj_player.stick_inventory) + " / " + string(obj_player.max_sticks));

// --- CONTROLS UI ---
var _gui_w = display_get_gui_width();
draw_set_halign(fa_right);

if (help_open) {
    draw_set_color(c_black);
    draw_set_alpha(0.8);
    draw_rectangle(_gui_w - 220, 20, _gui_w - 20, 160, false);
    draw_set_alpha(1);
    
    draw_set_color(c_white);
    draw_text(_gui_w - 30, 30, "CONTROLS");
    draw_text(_gui_w - 30, 60, "Move: W/A/S/D");
    draw_text(_gui_w - 30, 80, "Interact: " + global.get_key_name(global.key_interact));
    draw_text(_gui_w - 30, 100, "Toggle Grid: F2");
    draw_text(_gui_w - 30, 130, "Close Help: F1");
    
} else if (help_notif_alpha > 0) {
    draw_set_alpha(min(1, help_notif_alpha));
    draw_set_color(c_yellow);
    draw_text(_gui_w - 20, 20, "Press [F1] for Controls");
    draw_set_alpha(1);
}

draw_set_halign(fa_left);

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
