#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: TerrainLib_fnc_vehicleVelocitiesGet

Description:
    Get the velocities of all vehicles in an area

Parameters:
    _area - argument compatible with https://community.bistudio.com/wiki/BIS_fnc_getArea 
        [TRIGGER, MARKER, LOCATION, ARRAY]

Returns:
    A list of all vehicles in the area and their velocities

Examples:
    (BEGIN EXAMPLE)
        [[player, 500]] call TerrainLib_fnc_vehicleVelocitiesGet
    (END EXAMPLE)

Author:
    Seb
---------------------------------------------------------------------------- */
params ["_area"];

(vehicles inAreaArray _area) apply {[_x, velocity _x]}
