// Initialize Depth Sorting
// Even though this is decoration, we want player to walk behind/in-front correctly
scr_update_depth();

// Static decoration, no need for animation usually
image_speed = 0;
image_index = irandom(image_number - 1); // Random variant if available
