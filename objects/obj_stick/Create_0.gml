// Initialize Depth Sorting for Static Object
scr_update_depth();

// Pick random variant (stick has 3 frames/variants)
image_speed = 0; // Stop animation
image_index = irandom(image_number - 1); // Random frame (0, 1, or 2)
