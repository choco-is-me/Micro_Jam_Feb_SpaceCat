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
#macro PLAYER_EYE_ANIM_SPEED 4   // Frames per second (Lower is scarier)
#macro PLAYER_EYE_PAUSE_DURATION 2.0 // Seconds to hold the wide-eye stare

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
#macro CAMPFIRE_MAX_RADIUS 130   // New: Absolute Max Radius (at 100% fuel)
#macro CAMPFIRE_INTERACT_RADIUS 50  // Tighter interaction range


// World

#macro TILE_SIZE 32
#macro TOTAL_CLUES_NEEDED 7 // Max clues in world (Win Condition)
#macro MIN_CLUES_TO_SUBMIT 5 // Threshold for submitting (Partial/Bad Ending)


