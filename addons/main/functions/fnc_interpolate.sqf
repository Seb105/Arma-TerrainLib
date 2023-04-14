#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: TerrainLib_main_fnc_chunkOrigin

Description:
    Returns the origin (south-west) corner position of the chunk containing the provided position

Parameters:
    _pos - Position to check the chunk origin of [ARRAY]

Returns:
    The origin position of the chunk containing the provided position. Z is always 0. [ARRAY]

Examples:
    (begin example)
        _origin = [getPos player] call TerrainLib_main_fnc_chunkOrigin
        systemchat str ["The origin of your chunk is:", _origin]
    (end)

Author:
    Seb
---------------------------------------------------------------------------- */
params ["_alpha", "_power", "_smoothMode"];
switch (_smoothMode) do {
        // https://www.desmos.com/calculator/3lr40hyzkk
        case 0: {
            {
                // Linear interpolation
                params ["_alpha", "_power"];
                _alpha
            }
        };
        case 1: {
            {			
                // Ease in
                params ["_alpha", "_power"];
                _alpha^_power
            }
        };
        case 2: {
            {
                // Ease out
                params ["_alpha", "_power"];
                // Floating point errors cause an exception if alpha < 1
                _alpha = 0 max _alpha;
                _alpha^(1/_power)
            }
        };
        case 3: {
            {
                // EaseinOut
                params ["_alpha", "_power"];
                private _raised = _alpha^_power;
                _raised/(_raised+(1-_alpha)^_power)
            }
        };
        default {
            {
                // Default to linear
                params ["_alpha", "_power"];
                _alpha
            }
        };
    };
