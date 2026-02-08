// Draw Light Radius
gpu_set_blendmode(bm_add);
draw_set_color(c_orange);
draw_set_alpha(0.1 + (global.fuel/200));

// Calculate Center based on Bottom-Center Origin
// Light emanates from middle of campfire (flame/wood transition)
var _light_center = 11; // Center point at flame/wood junction
var _cx = x;
var _cy = y - (sprite_height - _light_center * image_yscale);

draw_circle(_cx, _cy, light_radius, false);

draw_set_alpha(1);
gpu_set_blendmode(bm_normal);

// Draw Campfire Sprite
// Origin is Bottom Center.
// MUST use draw_sprite_ext to respect the image_xscale/image_yscale set in Create event!
draw_sprite_ext(spr_campfire, floor(anim_frame), x, y, image_xscale, image_yscale, 0, c_white, 1);
 


