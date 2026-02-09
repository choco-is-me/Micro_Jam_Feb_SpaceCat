/// @description Menu Controller Initialization

// Menu state
menu_index = 0; // 0 = Start Game, 1 = Exit Game
menu_options = 2; // Total number of options

// Fade transition system
fade_state = "none"; // "none", "fade_out", "fade_in"
fade_alpha = 0; // 0 = fully visible, 1 = fully black
next_room = -1; // Room to transition to after fade

// GUI caching
gui_scale = 0;
gui_needs_recalc = true;

// Input debounce (prevent instant double-press)
input_cooldown = 0.2; // Seconds
input_timer = 0;

// Audio - Menu Campfire Ambience
campfire_sound_id = audio_play_sound(snd_campfire, 1, true);
audio_sound_gain(campfire_sound_id, CAMPFIRE_SOUND_VOLUME_MAX, 0);
