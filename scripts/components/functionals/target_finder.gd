## an area2D that enables finding targets of a given type
@icon("res://assets/node_icons/target_finder.png")
class_name TargetFinder
extends Area2D


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
# @export_group("Details")
#endregion


#region VARS
var _shape: CollisionShape2D
# info needed from parent
var max_range: float = 0:  ## this sets the radius of the area. updates radius when set.
	set(_value):
		max_range = _value
		_update_radius()
var team: Constants.TEAM  ## the team we're on
var target_option: Constants.TARGET_OPTION  ## the type of target we're looking for
#endregion


#region FUNCS
func _ready() -> void:
	_shape = get_node_or_null("CollisionShape2D")
	assert(_shape is CollisionShape2D, "Missing _shape")

## update the collision shape's radius to match max_range
func _update_radius() -> void:
	_shape.shape.radius = max_range

func update_collisions() -> void:
	Utility.update_body_collisions(self, team, target_option)

## returns nearest target that is within range. If no valid targets in range, returns null.
func get_nearest_target() -> CollisionObject2D:
	if max_range == 0:
		# will never find anyone
		return

	var nearest_body: CollisionObject2D
	var closest_distance: float = 0
	var new_distance: float = 0
	for body in get_overlapping_bodies():
		if nearest_body == null:
			nearest_body = body
			closest_distance = global_position.distance_to(body.global_position)
			continue

		new_distance = global_position.distance_to(body.global_position)
		if new_distance < closest_distance:
			nearest_body = body
			closest_distance = new_distance

	return nearest_body


#endregion
