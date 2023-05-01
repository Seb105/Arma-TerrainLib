#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: TerrainLib_fnc_alignPointsToGrid

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
    ]] call TerrainLib_fnc_alignPointsToGrid;
    (end)

Author:
    EL_D148L0
---------------------------------------------------------------------------- */
params [
    ["_positionsAndHeights", [], [[]]]
];


private _positionsHM = createHashMap;
getTerrainInfo params ["", "", "_cellSize", "_resolution", ""];
{
    private _xy = _x select [0,2];
    private _pos = _xy apply {
        (round (_x/_cellsize))*_cellSize
    };
    _pos set [2, _x#2];
    _positionsHM set [_xy, _pos];
} forEach _positionsAndHeights;

values _positionsHM
