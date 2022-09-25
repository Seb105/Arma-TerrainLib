#define COMPONENT main
#include "\z\TerrainLib\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_TerrainLib
    #define DEBUG_MODE_FULL
#endif
    #ifdef DEBUG_SETTINGS_OTHER
    #define DEBUG_SETTINGS DEBUG_SETTINGS_TerrainLib
#endif

#include "\z\TerrainLib\addons\main\script_macros.hpp"

#define CHUNKSIZE 8
