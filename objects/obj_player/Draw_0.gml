// Draw Player Sprite
draw_self();

// Draw Personal Light/Sense Radius (Centered on Body)
var _sprite_h = sprite_height; // This includes image_yscale automatically
var _cx = x;
var _cy = y - (_sprite_h / 2);

draw_set_color(c_white);
draw_set_alpha(0.15); // Lower alpha for subtlety
draw_circle(_cx, _cy, PLAYER_LIGHT_RADIUS, false);
draw_set_alpha(1);

