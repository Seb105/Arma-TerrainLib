#include "script_component.hpp"
/* ----------------------------------------------------------------------------
    Function: TerrainLib_main_fnc_getInterpolateFnc
    
    Description:
        Returns a function relating to the provided smooth mode.
    
    Parameters:
        _smoothMode - The smooth mode to use. [NUMBER]
    
    Returns:
        A function that takes two parameters, alpha and power, and returns a value between 0 and 1.
    
    Examples:
        (begin example)
            _fnc = [0] call TerrainLib_main_fnc_getInterpolateFnc;
        (end)
    
    Author:
        Seb
---------------------------------------------------------------------------- */
params ["_smoothMode"];
switch (_smoothMode) do {
    // https// www.desmos.com/calculator/3lr40hyzkk
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
            // default to linear
            params ["_alpha", "_power"];
            _alpha
        }
    };
};
