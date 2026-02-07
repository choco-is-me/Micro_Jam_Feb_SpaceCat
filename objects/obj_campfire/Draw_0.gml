draw_set_color(c_orange);
draw_set_alpha(0.3);
draw_circle(x, y, light_radius, false);
draw_set_alpha(1);

// Inner Fire Pit
draw_set_color(c_red); // Changed to red center for contrast
draw_circle(x, y, 12, false); // Reduced from 24

