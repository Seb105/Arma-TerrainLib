#include "script_component.hpp"
/* ----------------------------------------------------------------------------
        Function: TerrainLib_main_fnc_shapePositionAlpha
        
        Description:
            Returns a function which finds the alpha of this point within this shape.
            Alpha is 1 from the centre of the shape to the _size*_edgeSize. (which is dependent on _isRectangle)
            Alpha will then decrease from 1 to 0 at the edge.
        
            Some params for the shape are prepared outside this function, so this function doesn't duplicate work
            when called for many points in a shape
        
        Parameters:
            Of this function:
            _mode - Whether _a>_b of the shape. [BOOL]
            _isRectangle - Whether the shape is a rectangle. [BOOL]

            Of the returned function:
            _area - The area to find the alpha of. [ARRAY]
            _pos - The position to find the alpha of. [ARRAY]
            _delta - The difference between the longest and shortest side of the shape. [NUMBER]
            _flatSize - The size of flat area of the shape along the shortest edge [NUMBER]
            _blendedSize - The size of the blended area of the shape along the shortest edge [NUMBER]
            _edgeSize - The proportion of the blended area of the shape [NUMBER]

            
        
        
        Returns:
            Function which returns an alpha for a given point (0..1)[CODE]
        
        Examples:
            (BEGIN EXAMPLE)
                (_area call BIS_fnc_getArea) params ["_centre", "_a", "_b", "_angle", "_isRectangle", ""];]
                private _mode = _a>_b;
                private _delta = (abs (_a-_b));
                private _shortestEdge = _a min _b;
                private _flatSize = (1-_edgeSize) * _shortestEdge;
                private _blendedSize = (_edgeSize) * _shortestEdge;
                private _alpha = [_area, _pos, _delta, _flatSize, _blendedSize, _edgeSize] call TerrainLib_main_fnc_getShapePositionAlphaFnc;
            (END EXAMPLE)
        
        Author:
            Seb
---------------------------------------------------------------------------- */
params ["_mode", "_isRectangle"];

private _alphaFnc = if (_isRectangle) then {
    if (_mode) then {
        {
            params ["_area", "_pos", "_delta", "_flatSize", "_blendedSize", "_edgeSize"];
            _area params ["_centre", "_a", "_b", "_angle", "_isRectangle", ""];
            private _distance = _centre distance2D _pos;
            // direction this terrain point to centre of area
            private _dirTo = (_pos getDir _centre) - _angle;
            // Orthogonal distance in coordspace of the area.
            private _distA = abs (sin _dirTo) * _distance;
            private _distB = abs (cos _dirTo) * _distance;
            // Smooth off end of longest side at same ratio as shortest
            private _factorA = 0 max (( _distA - _delta - _flatSize )/ _blendedSize);
            // Smooth between edge of shortest edge and centre
            private _factorB = 0 max (( _distB - _flatSize )/ _blendedSize);
            1-(_factorA max _factorB)
        }
    } else {
        {
            params ["_area", "_pos", "_delta", "_flatSize", "_blendedSize", "_edgeSize"];
            _area params ["_centre", "_a", "_b", "_angle", "_isRectangle", ""];
            private _distance = _centre distance2D _pos;
            // direction this terrain point to centre of area
            private _dirTo = (_pos getDir _centre) - _angle;
            // Orthogonal distance in coordspace of the area.
            private _distA = abs (sin _dirTo) * _distance;
            private _distB = abs (cos _dirTo) * _distance;
            // Inverse of above when side lengths are reversed
            private _factorA = 0 max (( _distA - _flatSize ) / _blendedSize);
            private _factorB = 0 max (( _distB - _delta - _flatSize ) / _blendedSize);
            1-(_factorA max _factorB)
        }
    }
} else {
    {
        params ["_area", "_pos", "_delta", "_flatSize", "_blendedSize", "_edgeSize"];
        _area params ["_centre", "_a", "_b", "_angle", "_isRectangle", ""];
        private _distance = _centre distance2D _pos;
        // find point that lies on an ellipse at the angle to the curent point
        // Divide distance to current by point by to centre by distance to edge to get factor
        private _theta = (_centre getDir _pos) - _angle + 90;
        private _sinSquare = (1 - cos(2*_theta))/2;
        private _cosSquare = 1-_sinSquare;
                // Radius of ellipse at the current angle
        private _r = (_a*_b)/(sqrt (((_a^2)*_sinSquare)+((_b^2)*_cosSquare)));
        // size of blended area
        private _edgeDist = _edgeSize * _r;
        // 1..0 in blended area, clamped to 1.
        1 min ((_r-_distance)/_edgeDist)
    }
};
_alphaFnc
