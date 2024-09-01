## a component to hold a series of projectiles
@icon("res://assets/node_icons/rotate.png")
class_name ProjectileOrbiterComponent
extends Node2D


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
@export_group("Details")
@export var _max_projectiles: int = 10
@export var _orbit_scale: float = 30
@export var _rotation_speed: float = PI
#endregion


#region VARS
var _projectiles: Array[VisualProjectile] = []
var _num_projectiles:
	set(value):
		push_error("ProjectileOrbiterComponent: Can't set `_num_projectiles` directly.")
	get:
		return _projectiles.size()
var _points: Array = []
var has_max_projectiles: bool:
	set(value):
		push_error("ProjectileOrbiterComponent: Can't set `has_max_projectiles` directly.")
	get:
		return _num_projectiles == _max_projectiles

#endregion


#region FUNCS
func _ready() -> void:
	_generate_points_in_circle()

func _process(delta):
	rotation += _rotation_speed * delta

## calculate evenly spaced points around a circle based on number of projectiles
func _generate_points_in_circle():
	if _max_projectiles != 0:
		var increment = float(360) / float(_max_projectiles)
		var angle = 0

		_points.clear()
		var i = 0
		while angle < float(360):
			var x = cos(deg_to_rad(angle))
			var y = sin(deg_to_rad(angle))

			var point = Vector2(x * _orbit_scale, y * _orbit_scale)
			_points.append(point)

			i += 1
			angle += increment

## adds a projectile to the orbit. Recalculates position of all projectiles in orbit.
func add_projectile(projectile: VisualProjectile) -> void:
	if _num_projectiles + 1 <= _max_projectiles:  # +1 as we're about to add 1 and dont want to go over the limit
		_projectiles.append(projectile)
		# NOTE: it might look better if we assign to a random position in the circle
		#	or the furthest from the currently filled position
		projectile.position = _points[_projectiles.size() - 1]  # -1 to account for starting from 0

	else:
		push_warning("ProjectileOrbiterComponent: Tried to add more projectiles than the max allowed, so ignored.")

## removes a projectile to the orbit. Recalculates position of all projectiles in orbit.
func remove_projectile(projectile: VisualProjectile) -> void:
	_projectiles.erase(projectile)

#endregion
