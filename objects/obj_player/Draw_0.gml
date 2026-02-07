draw_set_color(c_lime);
draw_circle(x, y, PLAYER_VISUAL_SIZE, false);

// Draw Personal Light/Sense Radius
draw_set_color(c_white);
draw_set_alpha(0.15); // Lower alpha for subtlety
draw_circle(x, y, PLAYER_LIGHT_RADIUS, false);
draw_set_alpha(1);

