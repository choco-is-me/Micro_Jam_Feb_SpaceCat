/// @description Tutorial Controller Initialization

// Timer for auto-transition
display_timer = TUTORIAL_DISPLAY_TIME;

// Fade transition system
fade_state = "fade_in"; // "fade_in", "none", "fade_out", "dark_linger"
fade_alpha = 1; // Start with black screen

// Dark linger timer (for showing message on black screen)
dark_linger_timer = 1.5; // Seconds to show message
dark_linger_time = 0;

// Typing animation
typed_chars = 0; // Current number of characters shown
full_message = TUTORIAL_STARTING; // Store the full message
message_length = string_length(full_message);

// GUI caching
gui_scale = 0;
gui_needs_recalc = true;
