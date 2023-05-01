#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: TerrainLib_fnc_flattenTerrainArea

Description:
    Flatten the terrain by setting points within the specified area to a specified height.

Parameters:
    _area - argument compatible with https://community.bistudio.com/wiki/BIS_fnc_getArea 
        [TRIGGER, MARKER, LOCATION, ARRAY]
    _height - heightASL to set the height. Negative number lowers terrain [NUMBER]
    _adjustObjects - Adjust objects to new height [BOOL]
    _edgeSize - Number 0..1 controlling the size of the blended area between _height and the existing terrain.
        0 = No blending (Instant step between existing terrain and _height)
        0.5 = Half the distance to the centre will be _height, half will be transitional region
        1 = All blended (centre of _area will be _height, smooth transition between)
    _smoothMode - Interpolation function for _edgeSize
        0 - Linear
        1 - Smooth in
        2 - Smooth out
        3 - Smooth in & out
    [NUMBER]
    _smoothPower - How strong the smoothing mode is applied. Numbers less than 1 will result in odd behaviour. Default 2. Leave it as 2.
    [NUMBER]


Returns:
    False if not the server, or _positionsAndHeights that were actually set in-game after any event handlers [BOOL, ARRAY];

Examples:
    (BEGIN EXAMPLE)
        [[player, 500], (getPosASL player)#2, true, 0.5, 3, 2] call TerrainLib_fnc_flattenTerrainArea
    (END EXAMPLE)

Author:
    Seb
---------------------------------------------------------------------------- */
params [
    ["_areaArg", objNull, [objNull, "", locationNull, []]],
    ["_height" , 0, [0]],
    ["_adjustObjects", true, [true]],
    ["_edgeSize", 1, [1]],
    ["_smoothMode", 3, [1]],
    ["_smoothPower", 2, [1]]
];
if !(isServer) exitWith {false};
_edgeSize = 0 max (1 min _edgeSize);
private _positionsAndHeightsCurrent = [_areaArg] call TerrainLib_fnc_getAreaTerrainGrid;
private _interpolateFnc = [_smoothMode] call FUNC(getInterpolateFnc);

private _area = (_areaArg call BIS_fnc_getArea);
private _vehicleVelocities = if (_adjustObjects) then {
    [_area] call FUNC(vehicleVelocitiesGet)
};

private _positionsAndHeightsNew = if (_edgeSize != 0) then {
    _area params ["_centre", "_a", "_b", "_angle", "_isRectangle", ""];
    private _mode = _a>_b;
    private _delta = (abs (_a-_b));
    private _shortestEdge = _a min _b;
    private _flatSize = (1-_edgeSize) * _shortestEdge;
    private _blendedSize = (_edgeSize) * _shortestEdge;
    private _posAlphaFnc = [_mode, _isRectangle] call FUNC(getShapePositionAlphaFnc);
    _positionsAndHeightsCurrent apply {
        private _pos = _x;
        private _alpha = [_area, _pos, _delta, _flatSize, _blendedSize, _edgeSize] call _posAlphaFnc;
        _alpha = [_alpha, _smoothPower] call _interpolateFnc;
        private _currentZ = _pos#2;
        private _heightChange = (_height - _currentZ) * _alpha;
        _pos vectorAdd [0, 0, _heightChange]
    };
} else {
    _positionsAndHeightsCurrent apply {
        _x set [2, _height];
        _x
    }
};
private _positionsAndHeightsSet = [_positionsAndHeightsNew, _adjustObjects, true] call TerrainLib_fnc_setTerrainHeight;
if (_adjustObjects) then {
    [_vehicleVelocities] call FUNC(vehicleVelocitiesSet);
};

_positionsAndHeightsSet
