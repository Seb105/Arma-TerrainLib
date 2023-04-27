#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: TerrainLib_main_fnc_positionsAndHeightsToChunksLazy

Description:
    The same as the non lazy version but doesn't make sure that the points are properly aligned.
    This is useful if you know that the points are already aligned to the grid and want to the performance of checking

Parameters:
    _positionsAndHeights - array of [[x1,y1,z1], [x2,y2,z2]...]  [ARRAY]

Returns:
    Hashmap where the key is a string of origin position and the value is the [[x1,y1,z1], [x2,y2,z2]...]
    in chunk data format. [HASHMAP]

Examples:
    (begin example)
    private _chunkData = [
        [
            [1000, 1000, 25], 
            [1005, 1000, 25], 
            [1000, 1005, 25], 
            [1005, 1005, 25]
        ]
    ] call TerrainLib_main_fnc_positionsAndHeightsToChunksLazy;
    {
        private _origin = parseSimpleArray _x;
        private _chunkPositionsAndHeights = _y;
    } forEach _chunkData;
    (end)

Author:
    Seb
---------------------------------------------------------------------------- */
params [
    ["_positionsAndHeights", [], [[]]]
];

private _fnc_chunkGetOrDefault = {
    params ["_pos", "_chunksData"];
    getTerrainInfo params ["", "", "_cellSize", "_resolution", ""];
    // Nearest chunk origin (bottom-left)
    _pos = [_pos] call FUNC(chunkOrigin);
    private _hash = str _pos;
    private _chunkPositionsAndHeights = _chunksData get _hash;
    if (isNil "_chunkPositionsAndHeights") then {
        _chunkPositionsAndHeights = [_pos] call FUNC(getChunk);
        _chunksData set [_hash, _chunkPositionsAndHeights];
    };
    [_pos, _chunkPositionsAndHeights]
};

getTerrainInfo params ["", "", "_cellSize", "_resolution", ""];
// Cache calls to chunk builder
private _chunksData = createHashMap;
{
    private _pos = _x;
    private _chunkInfo = [_pos, _chunksData] call _fnc_chunkGetOrDefault;
    _chunkInfo params ["_chunkOrigin", "_chunkPositionsAndHeights"];
    private _indices = (_pos vectorDiff _chunkOrigin) vectorMultiply (1/_cellSize);
    _indices params ["_indexX", "_indexY"];
    // List of points is a flat array but is ordered so calc and set index
    private _index = CHUNKSIZE*_indexX + _indexY;
    _chunkPositionsAndHeights set [_index, _pos];
} forEach _positionsAndHeights;

_chunksData
