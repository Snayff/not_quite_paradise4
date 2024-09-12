## apply forces to the attached physics node
@icon("res://assets/node_icons/phys_move.png")
class_name PhysicsMovementComponent
extends Node

# TODO: move these to a stat sheet, as they vary by actor
const WALK_ACCEL = 1000.0
const WALK_DEACCEL = 1000.0
const WALK_MAX_VELOCITY = 200.0
const MOVE_SPEED = 10.0


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
@export_group("Component Links")
@export var _root: PhysicsBody2D
## the sprite we're going to flip the facing of, based on direction
@export var _main_sprite: Node2D
@export_group("Details")
@export var is_attached_to_player: bool = false
#endregion


#region VARS
var _is_facing_left: bool = false
var _target_actor: CombatActor
var _current_target_pos: Vector2 = Vector2.ZERO
var _is_following_target_actor: bool = false
#endregion


#region FUNCS
func calc_movement(state: PhysicsDirectBodyState2D) -> void:
	var velocity: Vector2 = state.get_linear_velocity()
	var step: float = state.get_step()

	# get player input.
	if is_attached_to_player:
		velocity = _apply_input_movement_velocity(velocity, step)

	# calc direction to target
	elif _target_actor is CombatActor or _current_target_pos != Vector2.ZERO:

		# get or update target position
		if _is_following_target_actor or _current_target_pos == Vector2.ZERO:
			_current_target_pos = _target_actor.global_position

		# update velocity
		var movement: Vector2 = _root.global_position.direction_to(
			_target_actor.global_position
			) * MOVE_SPEED
		velocity = _root.global_position.lerp(_root.global_position + movement, step * WALK_ACCEL)

	# TODO: only amend facing if we intend to move in a direction. e.g. dont face direction
	#	because knocked back in that direction.
	_amend_facing(velocity, velocity.x < 0, velocity.x > 0)

	# apply gravity and set back the linear velocity.
	velocity += state.get_total_gravity() * step
	state.set_linear_velocity(velocity)

func set_target_actor(actor: CombatActor, is_following: bool) -> void:
	_target_actor = actor
	_is_following_target_actor = is_following

## amends given velocity by input and returns amended velocity
func _apply_input_movement_velocity(velocity: Vector2, delta: float) -> Vector2:
	var move_left := Input.is_action_pressed(&"move_left")
	var move_right := Input.is_action_pressed(&"move_right")
	var move_up := Input.is_action_pressed(&"move_up")
	var move_down := Input.is_action_pressed(&"move_down")

	# Process logic when character is on floor.
	if move_left and not move_right:
		if velocity.x > -WALK_MAX_VELOCITY:
			velocity.x -= WALK_ACCEL * delta
	elif move_right and not move_left:
		if velocity.x < WALK_MAX_VELOCITY:
			velocity.x += WALK_ACCEL * delta
	else:
		var xv := absf(velocity.x)
		xv -= WALK_DEACCEL * delta
		if xv < 0:
			xv = 0
		velocity.x = signf(velocity.x) * xv

	# up down
	if move_up and not move_down:
		if velocity.y > -WALK_MAX_VELOCITY:
			velocity.y -= WALK_ACCEL * delta
	elif move_down and not move_up:
		if velocity.y < WALK_MAX_VELOCITY:
			velocity.y += WALK_ACCEL * delta
	else:
		var yv := absf(velocity.y)
		yv -= WALK_DEACCEL * delta
		if yv < 0:
			yv = 0
		velocity.y = signf(velocity.y) * yv

	return velocity

## amend the attached sprites facing based on movement and velocity
func _amend_facing(velocity: Vector2, move_left: bool, move_right: bool) -> void:
	var new_facing_left := _is_facing_left

	# Check facing
	if velocity.x < 0 and move_left:
		new_facing_left = true
	elif velocity.x > 0 and move_right:
		new_facing_left = false

	# Update facings
	if new_facing_left != _is_facing_left:
		if new_facing_left:
			# some nodes just need the x axis flipping
			_main_sprite.scale.x = -1

			# but some nodes need their relative position flipping, too
			if _main_sprite.position.x != 0:
				_main_sprite.position.x = _main_sprite.position.x * -1
		else:
			_main_sprite.scale.x = 1

			if _main_sprite.position.x != 0:
				_main_sprite.position.x = _main_sprite.position.x * -1

	_is_facing_left = new_facing_left




#endregion
