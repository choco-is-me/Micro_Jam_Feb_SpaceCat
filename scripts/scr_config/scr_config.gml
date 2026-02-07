// --- GAME CONFIGURATION MACROS ---
// Centralized balance numbers for easy tuning
// CONVERTED TO "PER SECOND" UNITS FOR DELTA TIME

// Visuals
#macro FONT_MAIN Font

// Player
#macro PLAYER_SPEED 240          // 4 px/frame * 60 = 240 px/sec

#macro PLAYER_MAX_STICKS 5
#macro INTERACT_RANGE 32         // Reduced from 40 for tighter feel
#macro PLAYER_LIGHT_RADIUS 48    // Added: Personal light bubble
#macro PLAYER_VISUAL_SIZE 10     // Added: Smaller visual footprint

// Enemy
#macro ENEMY_SPEED 252           // 4.2 px/frame * 60 = 252 px/sec
#macro ENEMY_SPAWN_INTERVAL 0.8  // Approx (100/2) frames ~ 50 frames ~ 0.83 sec. Logic changed to timer.
#macro ENEMY_DAMAGE_SANITY 30

// Sanity (Per Second)
#macro SANITY_MAX 100
#macro SANITY_REGAIN_LIGHT 2     // +2% per second
#macro SANITY_DRAIN_DARK 1       // -1% per second
#macro SANITY_DRAIN_STILL 2      // -2% per second
#macro TIME_BEFORE_STILL_PENALTY 1 // Seconds

// Campfire
#macro FUEL_MAX 100
#macro FUEL_DRAIN_RATE 3.0       // 0.05 * 60 = 3.0% per second
#macro FUEL_PER_STICK 20
#macro CAMPFIRE_BASE_RADIUS 50   // Reduced from 100
#macro CAMPFIRE_FUEL_MULTIPLIER 0.8 // Reduced from 3 to 0.8 (Max Size = 50 + 80 = 130)
#macro CAMPFIRE_INTERACT_RADIUS 50  // Tighter interaction range

// World

#macro TILE_SIZE 32
#macro TOTAL_CLUES_NEEDED 5

