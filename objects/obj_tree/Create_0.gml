// Randomize Tree Variant
// Stop animation
image_speed = 0;

// Pick random frame (0 or 1)
image_index = irandom(image_number - 1);

// Scale up to be larger than player
var _scale = random_range(2.5, 3.5);
image_xscale = _scale;
image_yscale = _scale;

// Static depth sort
scr_update_depth();

