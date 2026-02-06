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
    
    if (dist < effective_radius) {
         global.sanity += 0.05;
    } else {
         global.sanity -= 0.05;
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
