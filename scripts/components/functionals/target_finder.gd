## an area2D that enables finding targets of a given type
@icon("res://assets/node_icons/target_finder.png")
class_name TargetFinder
extends Area2D


#region SIGNALS
signal new_target(target: CombatActor)
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
var current_target: CombatActor
var _refresh_duration: float = 0.3  ## how long to wait before looking for a new target
var _refresh_counter: float = 0
# info needed from parent
var _max_range: float = 0  ## this sets the radius of the area.
var _target_option: Constants.TARGET_OPTION  ## the type of target we're looking for
var _root: CombatActor  ## the combat actor who owns this combat active this is attached to
var _allegiance: Allegiance  ## we take this, and not team directly, as Allegiance isnt init in parent before this is
var _is_debug: bool = true  ## whether to show debug stuff
var has_target: bool:  ## if target finder has a valid target
	set(_value):
		push_error("TargetFinder: Can't set has_target directly.")
	get:
		return current_target is CombatActor
#endregion


#region FUNCS
func _ready() -> void:
	_shape = get_node_or_null("CollisionShape2D")
	assert(_shape is CollisionShape2D, "Missing _shape")

	update_collisions()

func _process(delta: float) -> void:
	_refresh_counter -= delta
	if _refresh_counter <= 0:
		var nearest_target = get_nearest_target()
		if nearest_target != current_target:
			current_target = nearest_target
			new_target.emit(current_target)
		_refresh_counter = _refresh_duration

## update the collision shape's radius to match max_range
func _update_radius() -> void:
	_shape.shape.radius = _max_range

## update the body collision layers/masks
func update_collisions() -> void:
	if _allegiance is Allegiance and _target_option is Constants.TARGET_OPTION:
		Utility.update_body_collisions(self, _allegiance.team, _target_option)

## returns nearest target that is within range. If no valid targets in range, returns null.
func get_nearest_target() -> CombatActor:
	if _max_range == 0:
		# will never find anyone
		return

	var nearest_body: CollisionObject2D = null
	var closest_distance: float = 0
	var new_distance: float = 0
	var bodies = get_overlapping_bodies()
	for body in get_overlapping_bodies():
		# check target is one we care about
		if not Utility.target_is_valid(_target_option, _root, body):
			continue

		if nearest_body == null:
			nearest_body = body
			closest_distance = global_position.distance_to(body.global_position)
			continue

		new_distance = global_position.distance_to(body.global_position)
		if new_distance < closest_distance and nearest_body is CombatActor:
			nearest_body = body
			closest_distance = new_distance

	return nearest_body

func set_root(root: CombatActor) -> void:
	_root = root

## sets the required targeting info. also updates the collision's radius.
func set_targeting_info(max_range: float, target_option: Constants.TARGET_OPTION, allegiance: Allegiance) -> void:
	set_max_range(max_range)
	_target_option = target_option
	_allegiance = allegiance

	update_collisions()

func set_max_range(max_range: float) -> void:
	_max_range = max_range
	_update_radius()

#endregion
