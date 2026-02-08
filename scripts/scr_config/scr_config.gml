// --- GAME CONFIGURATION MACROS ---
// Centralized balance numbers for easy tuning
// CONVERTED TO "PER SECOND" UNITS FOR DELTA TIME

// Visuals
#macro FONT_MAIN Font

// Player
#macro PLAYER_SPEED 240          // 4 px/frame * 60 = 240 px/sec

#macro PLAYER_MAX_STICKS 5
#macro INTERACT_RANGE 32         // Reduced from 40 for tighter feel
#macro PLAYER_VISUAL_SIZE 10     // Added: Smaller visual footprint
#macro PLAYER_EYE_ANIM_SPEED 10   // Frames per second (faster = less warning time)
#macro PLAYER_EYE_PAUSE_DURATION 0.5 // Seconds to hold the wide-eye stare
#macro PLAYER_IDLE_ANIM_SPEED 3  // Frames per second for idle animation (slower = calmer)
#macro PLAYER_RUN_ANIM_SPEED 12  // Frames per second for running animation (faster = energetic)

// Enemy
#macro ENEMY_SPEED 252           // 4.2 px/frame * 60 = 252 px/sec
#macro ENEMY_DAMAGE_SANITY 30
#macro ENEMY_FREEZE_DURATION 3.0 // Seconds to idle after hitting player
#macro ENEMY_IDLE_ANIM_SPEED 6   // Frames per second for idle animation (slower = creepier)
#macro ENEMY_RUN_ANIM_SPEED 15   // Frames per second for running animation (faster = aggressive)

// Enemy Spawn Rate System (Probability-based)
// Note: Checked every frame (60 FPS), so rates are per-frame
// Formula: avg_spawn_time = 1 / (chance_per_frame * 60)
#macro ENEMY_SPAWN_BASE_CHANCE 0.001  // ~0.1% per frame
#macro ENEMY_SPAWN_MAX_CHANCE 0.005    // ~0.5% per frame
#macro ENEMY_SPAWN_DISTANCE_MIN 150    // Distance where spawn rate starts increasing
#macro ENEMY_SPAWN_DISTANCE_MAX 400    // Distance where spawn rate is maximum

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
#macro CAMPFIRE_ANIM_SPEED 10    // Frames per second
#macro CAMPFIRE_LIGHT_CENTER_OFFSET 11 // Visual offset from sprite origin to flame center

// Menu & Tutorial
#macro MENU_OPTION_START_Y_OFFSET -25 + 50  // Offset from center for start option
#macro MENU_OPTION_EXIT_Y_OFFSET 25 + 50    // Offset from center for exit option
#macro MENU_NAV_HINT_Y_OFFSET 30       // Offset from bottom for navigation hint
#macro MENU_CURSOR_OFFSET_X -20        // Horizontal offset for cursor from menu text
#macro MENU_FADE_SPEED 2.0             // Fade transition speed (0 to 1 per second)
#macro TUTORIAL_DISPLAY_TIME 3.0       // Seconds to show tutorial before auto-transition
#macro TUTORIAL_SPRITE_SPACING 280     // Horizontal spacing between tutorial sprites
#macro TUTORIAL_TEXT_Y_OFFSET 60       // Vertical offset for text below sprites
#macro TUTORIAL_SPRITE_SCALE 3.0       // Scale multiplier for tutorial sprites (makes them visible)
#macro TUTORIAL_MESSAGE_TYPING_SPEED 30 // Characters per second for "darkness awaits" message

// Camera
#macro CAMERA_SMOOTH_DECAY 10    // Delta time smoothing factor (higher = snappier)
#macro CAMERA_SPAWN_MARGIN 50    // Pixels outside view for enemy spawning
#macro CAMERA_SPAWN_SAFETY_MARGIN 32 // Extra margin from light radius

// UI
#macro UI_MARGIN 20              // Base UI margin
#macro UI_ICON_SIZE_BASE 32      // Base icon size before scaling
#macro UI_PADDING 15             // Padding for UI boxes
#macro UI_HELP_FADE_SPEED 1.0    // Help notification fade speed (per second)

// Dialog System (Clue Typing Animation)
#macro DIALOG_CHARS_PER_SECOND 50      // Characters revealed per second (faster for readability)
#macro DIALOG_LINGER_DURATION 2.0      // Seconds to show complete text before auto-advance
#macro DIALOG_FADE_SPEED 3.0           // Alpha fade speed when disappearing (per second, faster)
#macro DIALOG_BG_PADDING 10            // Background box padding
#macro DIALOG_Y_OFFSET -60             // Offset above player head (higher to avoid sanity bar)
#macro DIALOG_WIDTH_PERCENT 0.75       // Percentage of camera width for dialog box (75%)
#macro DIALOG_MAX_ROWS 2               // Maximum number of text rows to prevent blocking UI

// World

#macro TILE_SIZE 32
#macro TOTAL_CLUES_NEEDED 7 // Max clues in world (HIDDEN FROM PLAYER - Creates mystery & tension)
#macro MIN_CLUES_TO_SUBMIT 5 // Threshold for submitting (Allows partial ending trap)

// Spawn System
#macro SPAWN_COLLISION_CHECK_RADIUS 56 // Radius to check for collisions when spawning (max bush ~36px + item ~12px + 8px buffer)
#macro SPAWN_EDGE_MARGIN 80 // Minimum distance from room edges for spawning items (prevents edge spawns)

// Ending Cinematic System
#macro ENDING_FADE_SPEED 1.5           // Fade to black speed (per second)
#macro ENDING_TEXT_CHARS_PER_SECOND 30 // Typing speed for ending text
#macro ENDING_TEXT_LINGER 3.0          // Seconds to show complete ending before prompt
#macro ENDING_THANKYOU_LINGER 3.0      // Seconds to show thank you screen


