#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: TerrainLib_fnc_alignToTerrainPoints

Description:
    Given an Array of Positions and Heights, return the positions and heights that would result from the automatic aligning process in TerrainLib_fnc_setTerrainHeight

Parameters:
    _positionsAndHeights - array of [[x1,y1,z1], [x2,y2,z2]...]  [ARRAY]

Returns:
    Positions and Heights usable with lazy setTerrainHeight [ARRAY] 

Examples:
    (begin example)
    [[
        [1002.7, 1000, 25], 
        [1005, 1000, 25], 
        [1000, 1005, 25], 
        [1005, 1005, 25]
    ]] call TerrainLib_fnc_alignToTerrainPoints;
    (end)

Author:
    EL_D148L0
---------------------------------------------------------------------------- */
params [
    ["_positionsAndHeights", [], [[]]]
];


private _positionsHM = createHashMap;

{
    private _pos = [_x] call TerrainLib_fnc_nearestTerrainPoint;
    _pos set [2, _x#2];
    _positionsHM set [[_pos#0, _pos#1], _pos];
} forEach _positionsAndHeights;

values _positionsHM;