spd = ENEMY_SPEED;

// State Machine
state = "chasing"; // "chasing" or "frozen"
freeze_timer = 0;

// Animation Settings (Delta Time Corrected)
image_speed = 0; // Disable built-in animation (use manual control for delta time)
anim_frame = 0;
anim_speed = ENEMY_RUN_ANIM_SPEED; // Start with running speed (chasing is default)

// Audio: Play scream sound when spawned (one-shot, no cleanup needed)
audio_play_sound(snd_scream, 10, false);
audio_sound_gain(snd_scream, SCREAM_SOUND_VOLUME, 0);


