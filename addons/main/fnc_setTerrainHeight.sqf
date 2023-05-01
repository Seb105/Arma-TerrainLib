#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: TerrainLib_fnc_setTerrainHeight

Description:
    Replicate functionality of setTerrainHeight command, but internally split the provided set of 
    positions up into 'chunks' and save the resulting changes for save serialisation/deserialisation

    Calls the "Terrainlib_terrainHeightChanged" local event on the server with the following params:
    _positionsAndHeights - array of [[x1,y1,z1], [x2,y2,z2]...]  [ARRAY]
    _adjustObjects - move objects with terrain [BOOL]

    The EH is called before the terrain is actually updated, and as arrays are passed by reference if you mutate the input array you mutate the result.
    The terrain points passed to this function should already be aligned to the terrain grid, so you don't need to check that here.
    You can't just overwrite the array variable with a new one, you have to mutate existing reference with the set command
    If you want to use the EH to modify the ouptut, use this method as calling setTerrainHeight again may cause an infinite loop.

Parameters:
    _positionsAndHeights - array of [[x1,y1,z1], [x2,y2,z2]...]  [ARRAY]
    _adjustObjects - if true then objects on modified points are moved up/down to keep the same ATL height  [BOOL]
    _lazy - If true then don't confirm that points provided align perfectly to terrain grid to save performance.
    You are effectively promising you've already done that step yourself, such as by using TerrainLib_fnc_getAreaTerrainGrid which does this for you.
    IF YOU USE THIS WRONG YOU WILL BREAK THE MOD AND I WILL FIND AND KILL YOU! DON'T USE IT IF YOU DONT UNDERSTAND! [BOOL]

Returns:
    False if not the server, or _positionsAndHeights that were actually set in-game after any event handlers [BOOL, ARRAY]

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
    ["_positionsAndHeightsIn", [], [[]]],
    ["_adjustObjects", true, [true]],
    ["_lazy", false, [false]] // DO NOT USE UNLESS YOU REALLY KNOW WHAT YOURE DOING
];
if !(isServer) exitWith {false};

// Don't modify input array to this function needs a copy if nothing is done
private _positionsAndHeights = if (_lazy) then {
    +_positionsAndHeightsIn
} else {
    [_positionsAndHeightsIn] call TerrainLib_fnc_alignPointsToGrid
};

// Local event will only be called on server due to above. As this is called before setTerrainHeight, if you mutate the input array you mutate the output here.
["TerrainLib_terrainHeightChanged", [_positionsAndHeights, _adjustObjects]] call CBA_fnc_localEvent;

// Deprecate non-lazy version as alignment happens above
private _chunksData = [_positionsAndHeights] call FUNC(positionsAndHeightsToChunksLazy);

{
    private _key = _x;
    private _chunkPositionsAndHeights = _y;
    setTerrainHeight [_chunkPositionsAndHeights, _adjustObjects];
    // Wiki is wrong, don't need to serialise terrain ourselves, but is useful cache for speed probably
    GVAR(modifiedTerrainChunks) set [_key, [_chunkPositionsAndHeights, _adjustObjects]];
} forEach _chunksData;

_positionsAndHeights
