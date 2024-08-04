## apply movement to the attached node
@icon("res://assets/node_icons/move.png")
class_name MovementComponent
extends Node

#region EXPORTS
@export_category("Component Links")
@export var root: Node2D  ## physical or non physical node. Rigidbody2D is the only physical node handled.
@export var _travel_resource: ResourceComponent  ## the resource drained when the parent is moved
@export_category("Config")
#endregion


#region VARS
# targeting
var target_actor: CombatActor  ## the actor being targeted. use when target updating required. preferred over target_position.
var target_position: Vector2  ## the position being targeted.
# internals
var direction: Vector2  ## direction towards target
var _movement_update_type: Constants.MOVEMENT_UPDATE_TYPE = Constants.MOVEMENT_UPDATE_TYPE.physics  ## updated based on type of root node
var _previous_position: Vector2 = Vector2.ZERO  ## the position we were at on the previous frame
# physics only
var force_magnitude: float
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
		var travelled: float = root.global_position.distance_to(_previous_position)
		_travel_resource.decrease(travelled)
		_previous_position = root.global_position

	# move the root
	if (is_instance_valid(target_actor) or target_position != Vector2.ZERO) and _movement_update_type == Constants.MOVEMENT_UPDATE_TYPE.transform:
		_update_direction()
		var movement: Vector2 = direction * move_speed
		root.global_position = root.global_position.lerp(root.global_position + movement, delta * acceleration)  # NOTE: no idea if this works
		#move_toward(root.global_position, movement, delta)
		#lerp(velocity, MAX_SPEED * direction, delta * ACCELERATION)}

func _physics_process(delta: float) -> void:
	# give the new force to the root. due to needing the physics node at top level it must handle its own movement
	# meaning we just send it the info it needs.
	# NOTE: should this be a signal, as signal up?
	if (is_instance_valid(target_actor) or target_position != Vector2.ZERO) and _movement_update_type == Constants.MOVEMENT_UPDATE_TYPE.physics:
		_update_direction()
		var force = direction * force_magnitude
		root.force = force

		# rotate towards target
		root.rotation = direction.angle()

func _update_direction() -> void:
	if target_actor is CombatActor:
		#direction = target_actor.global_position - root.global_position
		direction = root.global_position.direction_to(target_actor.global_position)

	elif  target_position != Vector2.ZERO:
		direction =  root.global_position.direction_to(target_position)

	else:
		push_error("MovementComponent: No target to move towards.")
		direction = Vector2.ZERO
#endregion
