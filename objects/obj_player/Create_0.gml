spd = PLAYER_SPEED;
stick_inventory = 0;
max_sticks = PLAYER_MAX_STICKS;
stand_timer = 0; // Timer to track how long player has been standing still

// Animation Settings (Delta Time Corrected)
image_speed = 0; // Disable built-in animation (use manual control for delta time)
anim_frame = 0;
anim_speed = PLAYER_IDLE_ANIM_SPEED; // Start with idle speed

// Interaction State
active_interact_target = noone;
active_interact_msg = "";

// Campfire-specific interaction state (can have multiple actions)
can_refuel_campfire = false;
can_submit_clues = false;
campfire_interact_msg = "";

// Dialog System (Clue Typing Animation)
dialog_queue = ds_queue_create(); // Queue to hold pending dialog texts
dialog_active = false; // Is a dialog currently displaying?
dialog_current_text = ""; // Full text of current dialog
dialog_visible_chars = 0; // Number of characters currently visible
dialog_char_timer = 0; // Timer for typing animation
dialog_linger_timer = 0; // Timer for showing complete text before fading
dialog_alpha = 1.0; // Alpha for fade-out effect
dialog_state = "idle"; // States: "idle", "typing", "lingering", "fading"

// Audio Management
running_sound_id = -1; // ID for footsteps loop
pickup_sound_cooldown = 0; // Cooldown timer to prevent pickup sound spam