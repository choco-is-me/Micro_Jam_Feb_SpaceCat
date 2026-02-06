randomize();
global.sanity = 100;
global.fuel = 100;
global.max_fuel = 100;
global.clues_collected = 0;
global.total_clues_needed = 5;
global.game_over = false;
global.game_won = false;
global.message = "";

// Spawn Center Objects if they don't exist
if (!instance_exists(obj_campfire)) {
    instance_create_layer(room_width/2, room_height/2, "Instances", obj_campfire);
}
if (!instance_exists(obj_player)) {
    instance_create_layer(room_width/2, room_height/2 + 60, "Instances", obj_player);
}

// Initial Resource Spawn
repeat(15) {
    var dist = random_range(200, room_width/2 - 50);
    var dir = random(360);
    var _x = room_width/2 + lengthdir_x(dist, dir);
    var _y = room_height/2 + lengthdir_y(dist, dir);
    instance_create_layer(_x, _y, "Instances", obj_stick);
}

repeat(5) {
    var dist = random_range(300, room_width/2 - 20);
    var dir = random(360);
     var _x = room_width/2 + lengthdir_x(dist, dir);
    var _y = room_height/2 + lengthdir_y(dist, dir);
    instance_create_layer(_x, _y, "Instances", obj_clue);
}
