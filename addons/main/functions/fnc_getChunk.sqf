#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: TerrainLib_main_fnc_getChunk

Description:
    Given a a coordinate, return all terrain points in the chunk containing the coordinate. 

Parameters:
    _pos = Position inside chunk [ARRAY]

Returns:
    Array of positions [[x1,y1,z1], [x2,y2,z2]...] [ARRAY]

Examples:
    (begin example)
    private _chunkData = [getPos player] call TerrainLib_main_fnc_getChunk;
    (end)

Author:
    Seb
---------------------------------------------------------------------------- */
params [
    ["_pos", [0,0,0], [[]], [2,3]]
];
_pos = [_pos] call FUNC(chunkOrigin);
private _key = str _pos;

// If this chunk has been modified, return the modified terrain cache
private _chunkPositionsAndHeights = GVAR(modifiedTerrainChunks) get _key;
if (!isNil "_chunkPositionsAndHeights") exitWith {_chunkPositionsAndHeights#0};

// Otherwise, get the terrain data from the engine
getTerrainInfo params ["", "", "_cellSize", "_resolution", ""];
private _chunkPositionsAndHeights = [];
for "_cellX" from 0 to CHUNKSIZE - 1 do {
    for "_cellY" from 0 to CHUNKSIZE - 1 do {
        private _coordPos = _pos vectorAdd ([_cellX, _cellY, 0] vectorMultiply _cellSize);
        _coordPos set [2, getTerrainHeight _coordPos];
        _chunkPositionsAndHeights pushBack _coordPos;
    };
};

// this is the first time getting this chunk, save original terrain.
if (isServer && {!(_key in GVAR(originalTerrainChunks))}) then {
    GVAR(originalTerrainChunks) set [_key, +_chunkPositionsAndHeights];
};

_chunkPositionsAndHeights
