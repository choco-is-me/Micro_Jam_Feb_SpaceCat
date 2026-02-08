/// @description Menu Logic & Transitions

// Calculate delta time (frame-independent)
var _dt = delta_time / 1000000; // Convert microseconds to seconds

// Input cooldown
if (input_timer > 0) {
    input_timer -= _dt;
}

// === FADE STATE MACHINE ===
switch(fade_state) {
    case "fade_out":
        fade_alpha += MENU_FADE_SPEED * _dt;
        if (fade_alpha >= 1) {
            fade_alpha = 1;
            // Transition to next room
            if (next_room != -1) {
                room_goto(next_room);
            }
            fade_state = "fade_in";
        }
        exit; // Don't process input during fade
        
    case "fade_in":
        fade_alpha -= MENU_FADE_SPEED * _dt;
        if (fade_alpha <= 0) {
            fade_alpha = 0;
            fade_state = "none";
        }
        exit; // Don't process input during fade
        
    case "none":
        // Normal menu operation
        break;
}

// === MENU NAVIGATION (Only when not fading) ===
if (input_timer <= 0) {
    // Up navigation
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
        menu_index--;
        if (menu_index < 0) menu_index = menu_options - 1;
        input_timer = input_cooldown;
    }
    
    // Down navigation
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
        menu_index++;
        if (menu_index >= menu_options) menu_index = 0;
        input_timer = input_cooldown;
    }
    
    // Confirm selection
    if (keyboard_check_pressed(vk_space)) {
        input_timer = input_cooldown;
        
        switch(menu_index) {
            case 0: // Start Game
                fade_state = "fade_out";
                next_room = Tutorial;
                break;
                
            case 1: // Exit Game
                game_end();
                break;
        }
    }
}
