if (global.game_over || global.game_won) exit;

var hinput = keyboard_check(ord("D")) - keyboard_check(ord("A"));
var vinput = keyboard_check(ord("S")) - keyboard_check(ord("W"));

if (hinput != 0 || vinput != 0) {
    var dir = point_direction(0, 0, hinput, vinput);
    x += lengthdir_x(spd, dir);
    y += lengthdir_y(spd, dir);
}

x = clamp(x, 0, room_width);
y = clamp(y, 0, room_height);

// Sanity
var campfire = instance_nearest(x, y, obj_campfire);
if (campfire != noone) {
    var dist = point_distance(x, y, campfire.x, campfire.y);
    var effective_radius = (global.fuel > 0) ? campfire.light_radius : 0;
    
    // Assuming 60 FPS
    if (dist < effective_radius) {
        // Inside Campfire Radius: +2% per second -> +2/60 per frame
         global.sanity += 2/60;
         stand_timer = 0; // Reset stand timer if safe
    } else {
        // Outside Campfire Radius: -1% per second -> -1/60 per frame
         global.sanity -= 1/60;
         
         // Check for Standing Still
         if (hinput == 0 && vinput == 0) {
             stand_timer++;
             // Active after 1 second (1 * 60 = 60 frames) - HARDCORE MODE
             if (stand_timer > 60) {
                 // penalty: -2% per second -> -2/60 per frame
                 global.sanity -= 2/60;
             }
         } else {
             stand_timer = 0;
         }
    }
}

global.sanity = clamp(global.sanity, 0, 100);
if (global.sanity <= 0) global.game_over = true;

// Interact
if (keyboard_check_pressed(ord("E"))) {
    // Campfire
    if (campfire != noone && point_distance(x, y, campfire.x, campfire.y) < 100) {
        if (stick_inventory > 0) {
            stick_inventory--;
            global.fuel += 20;
            if (global.fuel > 100) global.fuel = 100;
        }
    }
    
    // Stick
    var stick = instance_nearest(x, y, obj_stick);
    if (stick != noone && point_distance(x, y, stick.x, stick.y) < 32) {
        if (stick_inventory < max_sticks) {
            stick_inventory++;
            instance_destroy(stick);
        }
    }
    
    // Clue
    var clue = instance_nearest(x, y, obj_clue);
    if (clue != noone && point_distance(x, y, clue.x, clue.y) < 32) {
        global.clues_collected++;
        instance_destroy(clue);
        if (global.clues_collected >= global.total_clues_needed) global.game_won = true;
    }
}
