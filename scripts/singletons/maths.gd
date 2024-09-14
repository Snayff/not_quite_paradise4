## maths functions
extends Node


#region VARS

#endregion


#region FUNCS
## convert a polar coord to a cartesian one
func polar_to_cartesian(radius: float, theta: float) -> Vector2:
	var x = radius * cos(theta)
	var y = radius * sin(theta)
	return Vector2(x, y)








#endregion
