#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: TerrainLib_fnc_setTerrainHeight

Description:
    Replicate functionality of setTerrainHeight command, but internally split the provided set of 
    positions up into 'chunks' and save the resulting changes for save serialisation/deserialisation

Parameters:
    _positionsAndHeights - array of [[x1,y1,z1], [x2,y2,z2]...]  [ARRAY]
    _adjustObjects - if true then objects on modified points are moved up/down to keep the same ATL height  [BOOL]
    _lazy - If true then don't confirm that points provided align perfectly to terrain grid to save performance.
    You are effectively promising you've already done that step yourself, such as by using TerrainLib_fnc_getAreaTerrainGrid which does this for you.
    IF YOU USE THIS WRONG YOU WILL BREAK THE MOD AND I WILL FIND AND KILL YOU! DON'T USE IT IF YOU DONT UNDERSTAND! [BOOL]

Returns:
    Whether the terrain was successfully edited [BOOL];

Examples:
    (begin example)
    [
        [
            [1000, 1000, 25], 
            [1005, 1000, 25], 
            [1000, 1005, 25], 
            [1005, 1005, 25]
        ],
        true
    ] call TerrainLib_fnc_setTerrainHeight;
    (end)

Author:
    Seb
---------------------------------------------------------------------------- */
params [
    ["_positionsAndHeights", [], [[]]],
    ["_adjustObjects", true, [true]],
    ["_lazy", false, [false]] // DO NOT USE UNLESS YOU REALLY KNOW WHAT YOURE DOING
];
if !(isServer) exitWith {false};
private _chunksData = if (_lazy) then {
    [_positionsAndHeights] call FUNC(positionsAndHeightsToChunksLazy);
} else {
    [_positionsAndHeights] call FUNC(positionsAndHeightsToChunks);
};
{
    private _key = _x;
    private _chunkPositionsAndHeights = _y;
    setTerrainHeight [_chunkPositionsAndHeights, _adjustObjects];
    // Wiki is wrong, don't need to serialise terrain ourselves, but is useful cache for speed probably
    GVAR(modifiedTerrainChunks) set [_key, [_chunkPositionsAndHeights, _adjustObjects]];
} forEach _chunksData;
true
