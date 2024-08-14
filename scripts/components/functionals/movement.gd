## apply movement to the attached node via transformation of the position
@icon("res://assets/node_icons/move.png")
class_name MovementComponent
extends Node2D

#region EXPORTS
@export_group("Component Links")
@export var root: Node2D  ## physical or non physical node. Rigidbody2D is the only physical node handled.
@export var _travel_resource: ResourceComponent  ## the resource drained when the parent is moved
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
var _movement_update_type: Constants.MOVEMENT_UPDATE_TYPE = Constants.MOVEMENT_UPDATE_TYPE.physics  ## updated based on type of root node
var _previous_position: Vector2 = Vector2.ZERO  ## the position we were at on the previous frame
var is_attached_to_player: bool = false  ## if this component is attached to the player. determines some behaviours.
# physics only
var force_magnitude: float = 50
# transform only
var move_speed: float = 100
var acceleration: float  = 2

#endregion


#region FUNCS
func _ready() -> void:
	# check for mandatory properties set in editor
	assert(root is Node2D, "Misssing `root`. ")

	if root is RigidBody2D:
		_movement_update_type = Constants.MOVEMENT_UPDATE_TYPE.physics
	else:
		_movement_update_type = Constants.MOVEMENT_UPDATE_TYPE.transform


func _process(delta: float) -> void:
	# update travel resource; if empty it may auto self-destruct, based on [DeathTrigger] settings.
	if _travel_resource is ResourceComponent:
		if _previous_position == Vector2.ZERO:
			_previous_position = root.global_position
		else:
			var travelled: float = _previous_position.distance_to(root.global_position)
			_travel_resource.decrease(travelled * _amount_drained_on_move)
			_previous_position = root.global_position

	# move the root
	if (is_instance_valid(target_actor) or target_position != Vector2.ZERO) and _movement_update_type == Constants.MOVEMENT_UPDATE_TYPE.transform:
		_update_relation_to_target()
		var movement: Vector2 = direction * move_speed
		root.global_position = root.global_position.lerp(root.global_position + movement, delta * acceleration)

func _physics_process(delta: float) -> void:
	# give the new force to the root. due to needing the physics node at top level it must handle its own movement
	# meaning we just send it the info it needs.
	# NOTE: should this be a signal, as signal up?
	if (is_instance_valid(target_actor) or target_position != Vector2.ZERO) and _movement_update_type == Constants.MOVEMENT_UPDATE_TYPE.physics:
		_update_relation_to_target()
		var force = direction * force_magnitude * min(_distance_to_target, 1)  # get slower as we near target
		root.force = force

		# rotate towards target
		root.rotation = direction.angle()

	# if we are using physics, apply friction
	if _movement_update_type == Constants.MOVEMENT_UPDATE_TYPE.physics:

		# if nearly at 0 then zero off to prevent jittering
		if root.force.is_zero_approx():
			root.force = Vector2.ZERO
		else:
			var force_sign = root.force.sign()
			var gravity = force_sign * Vector2(Constants.FRICTION, Constants.FRICTION)
			var new_x = 0
			var new_y = 0
			if force_sign.x > 0:
				new_x = clampf(root.force.x - gravity.x, 0, root.force.x)
				new_y = clampf(root.force.y - gravity.y, 0, root.force.y)
			else:
				new_x = clampf(root.force.x - gravity.x, root.force.x, 0)
				new_y = clampf(root.force.y - gravity.y, root.force.y, 0)
			root.force = Vector2(new_x, new_y)

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
