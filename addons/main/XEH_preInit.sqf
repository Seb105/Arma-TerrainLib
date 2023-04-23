#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"

GVAR(modifiedTerrainChunks) = createHashMap;
GVAR(originalTerrainChunks) = createHashMap;

// Wiki is wrong, this isn't necessary. Terrain is saved.
// if !(isMultiplayer) then {
//     addMissionEventHandler ["Loaded", {
//         {
//             setTerrainHeight _y;
//         } forEach GVAR(modifiedTerrainChunks);
//     }];
// };
