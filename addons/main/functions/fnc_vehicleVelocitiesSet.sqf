#include "script_component.hpp"
/* ----------------------------------------------------------------------------
Function: TerrainLib_fnc_vehicleVelocitiesSet

Description:
    Set the velocities of a list of vehicles

Parameters:
    [_velocities] - [[vehicle, velocity], ...] - A list of vehicles and their velocities

Returns:
    Nothing

Examples:
    (BEGIN EXAMPLE)
        [[player, 500]] call TerrainLib_fnc_vehicleVelocitiesGet
    (END EXAMPLE)

Author:
    Seb
---------------------------------------------------------------------------- */
params ["_velocities"];
{
    _x params ["_vehicle", "_velocity"];
    [_vehicle,_velocity] remoteExec ["setVelocity",_vehicle];
} forEach _velocities
