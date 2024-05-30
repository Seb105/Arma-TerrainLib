// #include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: TerrainLib_fnc_getAreaTerrainGrid

Description:
    Returns all terrain points in the specified area

Parameters:
    _area - the area to get the terrain points within [
        TRIGGER, 
        MARKER, 
        LOCATION, 
        ARRAY in format [center, distance] or [center, [a, b, angle, rect]] or [center, [a, b, angle, rect, height]]
    ]
    see https://community.bistudio.com/wiki/BIS_fnc_getArea

Returns:
    Array of positions [[x1,y1,z1], [x2,y2,z2]...] [ARRAY]

Examples:
    (begin example)
        _allPoints = ["marker1"] call TerrainLib_fnc_getAreaTerrainGrid;
    (end)

Author:
    Seb
---------------------------------------------------------------------------- */

params ["_areaArg"];

getTerrainInfo params ["", "", "_cellSize", "_resolution", ""];
private _area = _areaArg call BIS_fnc_getArea;
_area set [5, -1]; // Ignore Z value from objects/markers
_area params ["_centre", "_halfWidth", "_halfLength", "_dir"];
// Get bounds of rectangle accounting for direction. This is in terrian resolution units not meters
private _maxCount = ((_halfWidth+_halfLength)*3)/_cellSize; // Lazy approximation of bounding box, always exit before then anyways
private _cellX = (round (_centre#0 / _cellSize)) * _cellSize;
private _cellY = (round (_centre#1 / _cellSize)) * _cellSize;

// Simplified flood fill algorithm to get all points in the area
private _positionsAndHeights = [];
POINTS = _positionsAndHeights;
private _offsetX = 0;
private _offsetY = _cellSize;
// Centre line
for "_l" from 1 to _maxCount do {
    private _p1 = [_cellX - _l * _cellSize, _cellY];
    private _p2 = [_cellX + (_l-1) * _cellSize, _cellY];
    private _in = false;
    if (_p1 inArea _area) then {
        _p1 set [2, getTerrainHeight _p1];
        _in = true;
        _positionsAndHeights pushBack _p1;
    };
    if (_p2 inArea _area) then {
        _p2 set [2, getTerrainHeight _p2];
        _in = true;
        _positionsAndHeights pushBack _p2;
    };
    if !(_in) then {
        break;
    };
};
for "_j" from 0 to _maxCount do {
    // Walk to the left until we hit the edge of the area
    for "_i" from 0 to _maxCount do {
        private _next = _offsetX - _cellSize;
        private _pos = [_cellX + _next, _cellY + _offsetY];
        if !(_pos inArea _area) then {
            break;
        };
        _offsetX = _next;
    };
    private _nextOffsetX = nil;
    private _offset = _offsetX;
    private _upY = _cellY + _offsetY;
    private _downY = _cellY - _offsetY;
    for "_k" from 0 to _maxCount do {
        private _posX = _cellX + _offset;
        private _posUp = [_posX, _upY];
        private _posDown = [_cellX - _offset, _downY];
        private _inAreaRow = false;
        if (_posUp inArea _area) then {
            _posUp set [2, getTerrainHeight _posUp];
            _positionsAndHeights pushBack _posUp;
            _inAreaRow = true;                
        };
        if (_posDown inArea _area) then {
            _posDown set [2, getTerrainHeight _posDown];
            _positionsAndHeights pushBack _posDown;
            _inAreaRow = true;
        };
        if (isNil "_nextOffsetX") then {
            private _up1 = [_posX, _upY + _cellSize];
            if (_up1 inArea _area) then {
                _nextOffsetX = _offset;
                _up1 set [2, getTerrainHeight _up1];
            };
        };
        if (!_inAreaRow) then {
            break;
        };
        _offset = _offset + _cellSize;
        sleep 0.05;
    };
    if (isNil "_nextOffsetX") then {
        break;
    };
    _offsetY = _offsetY + _cellSize;
    _offsetX = _nextOffsetX;
};

_positionsAndHeights
