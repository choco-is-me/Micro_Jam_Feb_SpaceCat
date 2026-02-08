// Logic Update: Radius is now purely linear based on fuel
// If fuel is 0, radius is 0.
light_radius = (global.fuel / FUEL_MAX) * CAMPFIRE_MAX_RADIUS;

// --- ANIMATION LOGIC ---

// 1. Determine Target Range
var _start_frame = 0;
var _end_frame = 0;

if (global.fuel <= 0) {
    _start_frame = 0;
    _end_frame = 0;
} 
else if (global.fuel <= 33) {
    _start_frame = 1;
    _end_frame = 4;
} 
else if (global.fuel <= 66) {
    _start_frame = 5;
    _end_frame = 8;
} 
else {
    _start_frame = 9;
    _end_frame = 12;
}

// 2. State Transition Check
// If current frame is way outside target range, snap it to start of new range
if (anim_frame < _start_frame || anim_frame > _end_frame) {
    // Snap to nearest side to be smoother? Or just reset?
    // Let's just snap to start for simplicity
    anim_frame = _start_frame;
    anim_dir = 1; // Reset direction
}

// 3. Ping Pong Logic (Only if range has magnitude)
if (_start_frame != _end_frame) {
    var _spd = CAMPFIRE_ANIM_SPEED * global.dt; 
    
    anim_frame += _spd * anim_dir;
    
    if (anim_frame >= _end_frame) {
        anim_frame = _end_frame;
        anim_dir = -1;
    } else if (anim_frame <= _start_frame) {
        anim_frame = _start_frame;
        anim_dir = 1;
    }
} else {
    // Static frame (Stage 0)
    anim_frame = _start_frame;
}

// Apply to built-in variable so we can use draw_self() potentially, 
// or just for consistency debugging
image_index = anim_frame;

