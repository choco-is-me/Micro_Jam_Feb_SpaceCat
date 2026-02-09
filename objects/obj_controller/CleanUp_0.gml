/// @description Clean up audio resources

// Stop all looping sounds to prevent memory leaks
if (audio_is_playing(campfire_sound_id)) {
    audio_stop_sound(campfire_sound_id);
}

if (audio_is_playing(heartbeat_sound_id)) {
    audio_stop_sound(heartbeat_sound_id);
}

// Clean up shader surface
if (surface_exists(shader_surface)) {
    surface_free(shader_surface);
}
