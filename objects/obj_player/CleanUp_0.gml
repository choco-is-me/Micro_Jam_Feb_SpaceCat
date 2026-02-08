// Clean up dialog queue
if (ds_exists(dialog_queue, ds_type_queue)) {
    ds_queue_destroy(dialog_queue);
}
