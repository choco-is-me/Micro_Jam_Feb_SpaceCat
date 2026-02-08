// Clue ID must be set by the spawning system
// Valid values: 1-7
clue_id = 0; // Default, should be overridden
clue_text = "";

// Function to initialize sprite and text based on clue_id
// Call this AFTER setting clue_id from the spawning system
initialize_clue = function() {
    // Set sprite based on clue_id
    switch(clue_id) {
        case 1: sprite_index = spr_clue_blood; break;
        case 2:
        case 3:
        case 4:
        case 5:
        case 6: sprite_index = spr_clue_note; break;
        case 7: sprite_index = spr_clue_footprint; break;
        default: sprite_index = spr_clue_note; break; // Fallback
    }
    
    // Get dialog text for this clue
    switch(clue_id) {
        case 1: clue_text = CLUE_1_TEXT; break;
        case 2: clue_text = CLUE_2_TEXT; break;
        case 3: clue_text = CLUE_3_TEXT; break;
        case 4: clue_text = CLUE_4_TEXT; break;
        case 5: clue_text = CLUE_5_TEXT; break;
        case 6: clue_text = CLUE_6_TEXT; break;
        case 7: clue_text = CLUE_7_TEXT; break;
        default: clue_text = "A mysterious clue..."; break;
    }
};

// Initialize Depth Sorting for Static Object
scr_update_depth();
