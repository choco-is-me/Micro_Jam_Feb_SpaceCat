/// @description Tutorial Logic & Transition

// Calculate delta time (frame-independent)
var _dt = delta_time / 1000000; // Convert microseconds to seconds

// === FADE STATE MACHINE ===
switch(fade_state) {
    case "fade_in":
        fade_alpha -= MENU_FADE_SPEED * _dt;
        if (fade_alpha <= 0) {
            fade_alpha = 0;
            fade_state = "none";
        }
        exit; // Don't count timer during fade-in
        
    case "fade_out":
        fade_alpha += MENU_FADE_SPEED * _dt;
        if (fade_alpha >= 1) {
            fade_alpha = 1;
            fade_state = "dark_linger";
            dark_linger_time = 0; // Reset linger timer
        }
        exit; // Don't count timer during fade-out
        
    case "dark_linger":
        // Stay on black screen and show message
        dark_linger_time += _dt;
        
        // Advance typing animation
        typed_chars += TUTORIAL_MESSAGE_TYPING_SPEED * _dt;
        if (typed_chars > message_length) {
            typed_chars = message_length;
        }
        
        if (dark_linger_time >= dark_linger_timer) {
            // Transition to main game
            room_goto(Room1);
        }
        exit;
        
    case "none":
        // Normal display - countdown timer
        if (display_timer > 0) {
            display_timer -= _dt;
            
            // When timer expires, start fade-out
            if (display_timer <= 0) {
                fade_state = "fade_out";
            }
        }
        break;
}
