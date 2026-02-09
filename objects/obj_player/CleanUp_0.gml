// Clean up dialog queue
if (ds_exists(dialog_queue, ds_type_queue)) {
    ds_queue_destroy(dialog_queue);
}

// Stop running sound to prevent memory leak
if (audio_is_playing(running_sound_id)) {
    audio_stop_sound(running_sound_id);
}
