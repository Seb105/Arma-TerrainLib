# Terrain Lib

## [Get it on Steam](https://steamcommunity.com/sharedfiles/filedetails/?id=2966168738)

This provides some useful functions which makes working with terrain much nicer by allowing you to use triggers, markers, and function-based areas to modify terrain as an area, with a ton of parameters.

It also fixes a problem of network optimisation in multiplayer when it comes to changing terrain heights. By default, when you modify group of terrain points, unless the exact same group has been updated before then all points will be sent over the network. This means that you might be sending the same group of terrain points over the network tens of times to JIPs - terrible for server performance. This mod uses an automatic chunking system to fix that, but only when using TerrainLib functions.

Additionally, vehicle velocities are set to 0 when modifying object heights. This fixes that as best as possible when using area commands.

- Easy, area-based terrain modification with lots of customisation parameters
- Automatic network optimisation for multiplayer (only when using TerrainLib commands)
- Fix vehicle velocity being set to 0 when changing object heights (area-based commands only)
- Increase compatibility between mods that depend on this mod

# How to use

## All commands which modify terrain are server only.

Converting your existing code to make use of network optimisation and CBA events is a single line change
```sqf
// Your existing code:
setTerrainHeight [_positionAndAltitudeArray, _adjustObjects];
// Your new code:
[_positionAndAltitudeArray, _adjustObjects] call TerrainLib_fnc_setTerrainHeight;
```
# Area-based commands:

## Add/subtract terrain height:
```sqf
/*
Parameters:
    _area - argument compatible with https://community.bistudio.com/wiki/BIS_fnc_getArea 
        [TRIGGER, MARKER, LOCATION, ARRAY]
    _height - height in metres to add. Negative number lowers terrain [NUMBER]
    _adjustObjects - Adjust objects to new height [BOOL]
    _edgeSize - Number 0..1 controlling the size of the blended area between _height and the existing terrain.
        0 = No blending (Instant step between existing terrain and _height)
        0.5 = Half the distance to the centre will be _height, half will be transitional region
        1 = All blended (centre of _area will be _height, smooth transition between)
        [NUMBER]
    _smoothMode - Interpolation function for _edgeSize
        0 - Linear
        1 - Smooth in
        2 - Smooth out
        3 - Smooth in & out
        [NUMBER]
    _smoothPower - How strong the smoothing mode is applied. Numbers less than 1 will result in odd behaviour. Default 2. Leave it as 2.
        [NUMBER]

Returns:
    False if not the server, or _positionsAndHeights that were actually set in-game after any event handlers [BOOL, ARRAY]

Example:
*/
[[player, 25], -15, true, 1, 2, 2] call TerrainLib_fnc_addTerrainHeight
```

## Flatten terrain area:
```sqf
/*
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
    False if not the server, or _positionsAndHeights that were actually set in-game after any event handlers [BOOL, ARRAY]

Example:
*/
[[player, 500], (getPosASL player)#2, true, 0.5, 3, 2] call TerrainLib_fnc_flattenTerrainArea
```

## Restore terrain height (only works for terrain that has been modified by TerrainLib):
```sqf
/*
Parameters:
    _area - argument compatible with https://community.bistudio.com/wiki/BIS_fnc_getArea 
        [TRIGGER, MARKER, LOCATION, ARRAY]
    _adjustObjects - Adjust objects to new height [BOOL]
    _edgeSize - Number 0..1 controlling the size of the blended area between _height and the existing terrain.
        0 = No blending (Instant step between existing terrain and _height)
        0.5 = Half the distance to the centre will be _height, half will be transitional region
        1 = All blended (centre of _area will be _height, smooth transition between)
        [NUMBER]
    _smoothMode - Interpolation function for _edgeSize
        0 - Linear
        1 - Smooth in
        2 - Smooth out
        3 - Smooth in & out
        [NUMBER]
    _smoothPower - How strong the smoothing mode is applied. Numbers less than 1 will result in odd behaviour. Default 2. Leave it as 2.
        [NUMBER]


Returns:
    False if not the server, or _positionsAndHeights that were actually set in-game after any event handlers [BOOL, ARRAY]

Example:
*/
[[player, 500], true, 0.5, 3, 2] call TerrainLib_fnc_restoreTerrainHeight
```
# CBA Events
Whenever terrain height is changed through TerrainLib, including the area functions, the following event is called: `"TerrainLib_terrainHeightChanged"`

You can use the event as follows:
```sqf
private _eventID = [
    "TerrainLib_terrainHeightChanged", {
        params ["_positionsAndHeights", "_adjustObjects"];
        // As _positionsAndHeights is passed by reference, we can change the heights in this event handler to change what actually happens in-game.
        (_positionsAndHeights#0) set [2, 5];
    }, ["hi"]
] call CBA_fnc_addEventHandlerArgs;
```
This event handler is called before the terrain height is actually set. 
Therefore, by modifying `_positionsAndHeights` by reference using `set` you can alter the output and change how the terrain is modified in-game.

`_positionsAndHeights` sent to this event handler will already be aligned to the terrain grid, so you don't need to double check that. For this reason it's recommended you do not move the XY positons of any points, as moving the positions off the terrain grid will cause issues.

It is not recommended to call `TerrainLib_fnc_setTerrainHeight` from inside this EH, as it is liable cause an infinite loop of event handlers triggering event handlers.
# Align points to terrain grid.
By default, `TerrainLib_fnc_setTerrainHeight` will align the points to a grid for you.

`TerrainLib_fnc_alignPointsToGrid` will align a list of points to the TerrainGrid, which you can call if you want

```sqf
/*
Parameters:
    _positionsAndHeights - array of [[x1,y1,z1], [x2,y2,z2]...]  [ARRAY]

Returns:
    Positions and Heights usable with lazy setTerrainHeight [ARRAY] 

Example:
*/
[[
    [1002.7, 1000, 25], 
    [1005, 1000, 25], 
    [1000, 1005, 25], 
    [1005, 1005, 25]
]] call TerrainLib_fnc_alignPointsToGrid;
```

Then, in `TerrainLib_fnc_setTerrainHeight`, you can set the `_lazy` arg to true, which is a promise that you are passing a list of points that are already aligned.


## Run this on the VR map in init.sqf for a nice demo of all the customisation features:
```sqf
private _eventID = [
    "TerrainLib_terrainHeightChanged", {
        params ["_positionsAndHeights", "_adjustObjects"];
        private _i = _thisArgs#0;
        _thisArgs set [0, _i + 1];
        systemchat (format ["%1: %2 points changed", _i, count _positionsAndHeights]);
    }, [0]
] call CBA_fnc_addEventHandlerArgs;

0 spawn {
    waitUntil {
        time>1
    };
    private _step = 200;
    private _start = [_step, _step, 0];
    private _current = +_start;
    private _num = 0;
    {
        private _smoothMode = _x;
        {
            private _edgeSize = _x;
            {
                private _isRectangle = _x;
                {
                    private _heightChange = _x;
                    {
                        private _a = _x;
                        private _b = 50;
                        {
                            private _angle = _x;
                            private _area = [_current, [_a, _b, _angle, _isRectangle]];
                            private _args = [_area, _heightChange, false, _edgeSize, _smoothMode, 2];
                            private _name = format ["%1 args: %2", _num, str _args];
                            _args call TerrainLib_fnc_addTerrainHeight;
                            private _marker = createMarkerLocal [_name, _current];
                            _marker setMarkerText _name;
                            _marker setMarkerType "hd_dot";
                            _current = _current vectorAdd [0, _step, 0];
                            _num = _num + 1;
                        } forEach [0, 45];
                    } forEach [25, 50, 75];
                } forEach [20, -5];
            } forEach [true, false];
            _start = _start vectorAdd [_step, 0, 0];
            _current = +_start;
        } forEach [0, 0.25, 0.5, 0.75, 1];
    } forEach [0, 1, 2, 3];
};
```
