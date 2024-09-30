## a component to hold a series of projectiles
@icon("res://components/functionals/orbiter.png")
class_name ProjectileOrbiterComponent
extends Node2D


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
@export_group("Details")
## max number of projectiles allower in the orbit. loaded from library.
@export var _max_projectiles: int = 6
## how quickly the projectiles circle the actor. loaded from library.
@export var _rotation_speed: float = PI
## the size of the circle that the projectiles follow
## 20 is about minimum for circling a 16x16 actor.
## 50-70 is getting quite far from the actor.
## loaded from library.
@export var _orbit_radius: float = 60.0
#endregion


#region VARS
var _projectiles: Array[ProjectileOrbital] = []
var _num_projectiles: int:
	set(value):
		push_error("ProjectileOrbiterComponent: Can't set `_num_projectiles` directly.")
	get:
		return _projectiles.size()
## the points in the orbit on which to place the projectiles
var _points: Array[Vector2] = []
# FIXME: we should really update _points, but can't work out how to do so.
#		by separating the angles and points like this the circles arent evenly spread
## the angle of each projectile in the orbit
var _angles: Array[float] = []
## if the orbiter has the maximum number of projectiles in orbit
var has_max_projectiles: bool:
	set(value):
		push_error("ProjectileOrbiterComponent: Can't set `has_max_projectiles` directly.")
	get:
		return _num_projectiles == _max_projectiles
## whether setup() has been run or not
var _has_run_setup: bool = false
#endregion


#region FUNCS
func setup(max_projectiles: int, orbit_radius: float, rotation_speed: float) -> void:
	_max_projectiles = max_projectiles
	_orbit_radius = orbit_radius
	_rotation_speed = rotation_speed

	_generate_points_in_circle()

	_has_run_setup = true

func _physics_process(delta: float) -> void:
	if not _has_run_setup:
		return

	for i in _projectiles.size():
		if not is_instance_valid(_projectiles[i]):
			break

		_angles[i] += _rotation_speed * delta

		var x_pos = cos(_angles[i])
		var y_pos = sin(_angles[i])
		_projectiles[i].global_position.x = _orbit_radius * x_pos + global_position.x
		_projectiles[i].global_position.y = _orbit_radius * y_pos + global_position.y

## calculate evenly spaced points around a circle based on number of projectiles
func _generate_points_in_circle():
	if _max_projectiles >= 0:
		var increment = clampf(float(360) / float(_max_projectiles), 1, 360)
		var angle = 0

		_points.clear()
		_angles.clear()
		@warning_ignore("unused_variable")  # godot thinks i is unused for some reason
		var i: int = 0
		while angle < float(360):
			var x = cos(deg_to_rad(angle))
			var y = sin(deg_to_rad(angle))

			var point = Vector2(x * _orbit_radius, y * _orbit_radius)
			_points.append(point)

			_angles.append(angle)

			i += 1
			angle += increment

## adds a projectile to the orbit. Recalculates position of all projectiles in orbit.
func add_projectile(projectile: ProjectileOrbital) -> void:
	if _num_projectiles + 1 <= _max_projectiles:  # +1 as we're about to add 1 and dont want to go over the limit
		_projectiles.append(projectile)
		# FIXME: need to use radial spreading to improve the look of spawnign new projectiles.
		#		also, this means currently a projectile can spawn where one has just expired,
		#		essentially double hitting.
		# FIXME: projectiles all grouping up together, not spread around circle
		projectile.position = _points[_projectiles.size() - 1] # -1 to account for starting from 0

	else:
		push_warning("ProjectileOrbiterComponent: Tried to add more projectiles than the max allowed, so ignored.")

## removes a projectile to the orbit. Recalculates position of all projectiles in orbit.
func remove_projectile(projectile: ProjectileOrbital) -> void:
	_projectiles.erase(projectile)


#endregion
