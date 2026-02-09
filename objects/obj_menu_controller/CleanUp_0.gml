/// @description Clean up audio resources

// Stop campfire sound to prevent memory leak
if (audio_is_playing(campfire_sound_id)) {
    audio_stop_sound(campfire_sound_id);
}
