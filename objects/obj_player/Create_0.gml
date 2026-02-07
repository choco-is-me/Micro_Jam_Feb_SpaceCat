spd = PLAYER_SPEED;
stick_inventory = 0;
max_sticks = PLAYER_MAX_STICKS;
stand_timer = 0; // Timer to track how long player has been standing still

// Interaction State
active_interact_target = noone;
active_interact_msg = "";

// Visual Effects
eye_anim_frame = 0;
eye_anim_dir = 1; // 1 for forward, -1 for backward
eye_anim_speed = PLAYER_EYE_ANIM_SPEED; 
eye_anim_pause_timer = 0;
eye_anim_pause_duration = PLAYER_EYE_PAUSE_DURATION;
is_being_watched = false;