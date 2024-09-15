## apply movement to the attached node via transformation of the position
@icon("res://components/functionals/move.png")
class_name MovementComponent
extends Node2D

#region EXPORTS
@export_group("Component Links")
@export var root: Node2D  ## physical or non physical node. Rigidbody2D is the only physical node handled.
@export var _travel_resource: SupplyComponent  ## the resource drained when the parent is moved
@export_group("Config")
@export_range(0, 0, 1, "or_greater") var _amount_drained_on_move: float = 0  ## how much of the resource is drained per pixel moved
#endregion


#region VARS
# targeting
var target_actor: CombatActor  ## the actor being targeted. use when target updating required. preferred over target_position.
var target_position: Vector2  ## the position being targeted.
# internals
var direction: Vector2  ## direction towards target
var _distance_to_target: float  ## how far we are from the target
var _previous_position: Vector2 = Vector2.ZERO  ## the position we were at on the previous frame
var move_speed: float = 100
var acceleration: float  = 2

#endregion


#region FUNCS
func _ready() -> void:
	# check for mandatory properties set in editor
	assert(root is Node2D, "Misssing `root`. ")

func _process(delta: float) -> void:
	# update travel resource; if empty it may auto self-destruct, based on [DeathTrigger] settings.
	# FIXME: this isnt working. No travel_resource is set, nothing happens.
	if _travel_resource is SupplyComponent:
		if _previous_position == Vector2.ZERO:
			_previous_position = root.global_position
		else:
			var travelled: float = _previous_position.distance_to(root.global_position)
			@warning_ignore("narrowing_conversion")  # happy with reduced precision
			_travel_resource.decrease(travelled * _amount_drained_on_move)
			_previous_position = root.global_position

	# move the root
	if is_instance_valid(target_actor) or target_position != Vector2.ZERO:
		_update_relation_to_target()
		var movement: Vector2 = direction * move_speed
		root.global_position = root.global_position.lerp(root.global_position + movement, delta * acceleration)

## update the values regarding the roots position relative to the target, such as [direction] and [distance_to_target].
func _update_relation_to_target() -> void:
	if target_actor is CombatActor:
		direction = root.global_position.direction_to(target_actor.global_position)
		_distance_to_target = root.global_position.distance_to(target_actor.global_position)

	elif  target_position != Vector2.ZERO:
		direction =  root.global_position.direction_to(target_position)
		_distance_to_target = root.global_position.distance_to(target_position)

	# dont change direction if we dont have someone or something to aim for
	else:
		pass


#endregion
