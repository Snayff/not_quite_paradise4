## apply forces to the attached physics node
@icon("res://components/functionals/physics_movement.png")
class_name PhysicsMovementComponent
extends Node


#region SIGNALS
## how far moved in last period. period define by [DISTANCE_CHECK_WAIT_TIME]
signal updated_distance_recently_moved(distance: float)
#endregion


#region ON READY

#endregion


#region EXPORTS
@export_group("Component Links")
## the body to apply forces to
@export var _root: PhysicsBody2D
@export_group("Details")
## divert logic to respond to controls rather than targeting
@export var is_attached_to_player: bool = false
#endregion


#region VARS
## an actor to use as a target destination.
##
## only used on initial setting unless `_is_following_target_actor == true`
var _target_actor: Actor
##  a fixed point to move towards
var _target_destination: Vector2 = Vector2.ZERO
var _target_direction: Vector2 = Vector2.ZERO
## the position current moving towards.
var _current_target_pos: Vector2 = Vector2.ZERO
## whether to update _current_target_pos to targets current position
var _is_following_target_actor: bool = false
## which targeting to use
##
## "destination" or "actor"
var _target_mode: Constants.MOVEMENT_TARGET_MODE = Constants.MOVEMENT_TARGET_MODE.none
## how long to reside in the _target_mode = "direction"
var _move_in_direction_duration: float = 0.0
## max movement speed. with _max_speed < accel < deccel we can get some random sidewinding movement,
## but still hit target. with move_speed >= accel we move straight to target
var _max_speed: float
## how quickly we accelerate. uses delta, so will apply ~1/60th per frame to the velocity,
## up to _max_speed.
var _acceleration: float
## how quickly we decelerate. uses delta, so will apply ~1/60th per frame to the velocity.
## applied when _max_speed is hit. should be >= _acceleration.
var _deceleration: float
## how far from target's pos can target.
##
## ignored when [member _is_following_target_actor] == true.
var _deviation: float
## whether setup() has been called
var _has_run_setup: bool = false
## how far the [member _root] moved this frame
var _distance_recently_moved: float = 0.0
## track time until next distance check
var _distance_timer: float = 0.0
## previous position, for checking distance moved
var _prev_pos: Vector2 = Vector2.INF

#endregion


#region FUNCS

##########################
####### LIFECYCLE #######
########################

func setup(
	max_speed_: float,
	acceleration_: float,
	deceleration_: float,
	deviation_: float = 0.0
	) -> void:
	_max_speed = max_speed_
	_acceleration = acceleration_
	_deceleration = deceleration_
	_deviation = deviation_

	_has_run_setup = true

func _process(delta: float) -> void:
	# count down duration of move in direction
	_move_in_direction_duration -= delta
	if _move_in_direction_duration <= 0 and _target_mode == Constants.MOVEMENT_TARGET_MODE.direction:
		_target_mode = Constants.MOVEMENT_TARGET_MODE.none

	# periodically track distance moved
	_distance_timer -= delta
	if _distance_timer <= 0:
		# if we havent captured previous position yet, update it and reset timer
		if _prev_pos == Vector2.INF:
			_prev_pos = _root.global_position
			_distance_recently_moved = 0.0

		else:
			# capture distance moved
			_distance_recently_moved = _prev_pos.distance_to(_root.global_position)
			updated_distance_recently_moved.emit(_distance_recently_moved)

			# update previous position
			_prev_pos = _root.global_position

		_distance_timer = Constants.DISTANCE_CHECK_WAIT_TIME

# TODO: eventually, this should just be the _physics process, so that it doesnt need to be called.
## update the physics state's velocity. won't run until setup() has been called.
func execute_physics(delta: float) -> void:
	if not _has_run_setup:
		return

	# not moving towards anything, so slow down to zero
	if _target_mode == Constants.MOVEMENT_TARGET_MODE.none:
		_decelerate_until_stop(delta)
		return

	if _root is ProjectileThrowable:
			pass#breakpoint

	# get current position to move towards
	if _target_mode == Constants.MOVEMENT_TARGET_MODE.actor and _target_actor is Actor:
		if _root is ProjectileThrowable:
			pass#breakpoint
		_current_target_pos = _target_actor.global_position

	elif _target_mode == Constants.MOVEMENT_TARGET_MODE.destination:
		_current_target_pos = _target_destination

	elif _target_mode == Constants.MOVEMENT_TARGET_MODE.direction:
		_current_target_pos = _target_direction * _max_speed

	# get direction to move to current target pos
	var movement_direction: Vector2 = _root.global_position.direction_to(_current_target_pos)

	# if direction is 0 then slow down
	if movement_direction.is_zero_approx():
		_decelerate_until_stop(delta)
		return

	# move towards target
	var movement: Vector2 = movement_direction * _acceleration * delta
	_root.apply_impulse(movement, _root.global_position)

	# debug to show where we're moving
	HyperLog.sketch_arrow(_root.global_position, movement, delta + 0.1)

##########################
####### PUBLIC  #########
########################

# TODO: remove and fold into physics process/execute physics above, so player uses same
## convert input into velocity
func apply_input_velocity(state: PhysicsDirectBodyState2D) -> void:
	var velocity: Vector2 = state.get_linear_velocity()
	var step: float = state.get_step()

	# get player input.
	if is_attached_to_player:
		var move_left := Input.is_action_pressed(&"move_left")
		var move_right := Input.is_action_pressed(&"move_right")
		var move_up := Input.is_action_pressed(&"move_up")
		var move_down := Input.is_action_pressed(&"move_down")

		velocity = _get_input_velocity(velocity, step, move_left, move_right, move_up, move_down)

	# apply gravity and set back the linear velocity.
	velocity += state.get_total_gravity() * step
	state.set_linear_velocity(velocity)

func set_target_actor(actor: Actor, is_following: bool) -> void:
	if is_following:
		_is_following_target_actor = is_following
		_target_actor = actor
		_target_mode = Constants.MOVEMENT_TARGET_MODE.actor

	else:
		_target_mode = Constants.MOVEMENT_TARGET_MODE.destination
		_update_target_destination(actor.global_position)

func set_target_destination(destination: Vector2) -> void:
	_target_mode = Constants.MOVEMENT_TARGET_MODE.destination
	_update_target_destination(destination)

## set a direction to move in, for the specified duration.
##
## does nothing if duration <= 0
func set_target_direction(direction: Vector2, duration: float) -> void:
	if duration <= 0:
		return

	_target_direction = direction
	_move_in_direction_duration = duration
	_target_mode = Constants.MOVEMENT_TARGET_MODE.direction

##########################
####### PRIVATE #########
########################

## update [member _target_destination] based on [member _target_mode] and applying
## [member _deviation]
func _update_target_destination(target_pos: Vector2) -> void:
	# get random value to deviate from target
	var deviation_x: float = randf_range(-_deviation, _deviation)
	var deviation_y: float = randf_range(-_deviation, _deviation)

	# apply deviation
	var x: float = target_pos.x
	var y: float = target_pos.y
	if deviation_x <= 0:
		x -= deviation_x
	else:
		x += deviation_x
	if deviation_y <= 0:
		y -= deviation_y
	else:
		y += deviation_y

	# set new value
	_target_destination = Vector2(x, y)


## apply _deceleration until stopped
func _decelerate_until_stop(delta: float) -> void:
	var current_velocity: Vector2 = _root.linear_velocity

	if current_velocity.is_zero_approx():
		_root.linear_velocity = Vector2.ZERO

	var slow_down_force: Vector2 = Vector2.ZERO
	var set_x_zero: bool = false
	if current_velocity.x > 0:
		if current_velocity.x < _deceleration * delta:
			set_x_zero = true
		else:
			slow_down_force.x = -min(current_velocity.x, _deceleration * delta)

	elif current_velocity.x < 0:
		if current_velocity.x > -_deceleration * delta:
			set_x_zero = true
		else:
			slow_down_force.x = max(current_velocity.x, _deceleration * delta)

	var set_y_zero: bool = false
	if current_velocity.y > 0:
		if current_velocity.y < _deceleration *delta:
			set_y_zero = true
		else:
			slow_down_force.y = -min(current_velocity.x, _deceleration * delta)

	elif current_velocity.y < 0:
		if current_velocity.y > -_deceleration * delta:
			set_y_zero = true
		else:
			slow_down_force.y = max(current_velocity.y, _deceleration * delta)

	# apply slowdown
	_root.apply_impulse(slow_down_force, _root.global_position)

	if set_x_zero:
		_root.linear_velocity.x = 0
	if set_y_zero:
		_root.linear_velocity.y = 0

func _get_input_velocity(velocity: Vector2, delta: float, move_left: bool, move_right: bool, move_up: bool, move_down: bool) -> Vector2:

	if move_left and not move_right:
		if velocity.x > -_max_speed:
			velocity.x -= _acceleration * delta
	elif move_right and not move_left:
		if velocity.x < _max_speed:
			velocity.x += _acceleration * delta
	else:
		var xv := absf(velocity.x)
		xv -= _deceleration * delta
		if xv < 0:
			xv = 0
		velocity.x = signf(velocity.x) * xv

	# up down
	if move_up and not move_down:
		if velocity.y > -_max_speed:
			velocity.y -= _acceleration * delta
	elif move_down and not move_up:
		if velocity.y < _max_speed:
			velocity.y += _acceleration * delta
	else:
		var yv := absf(velocity.y)
		yv -= _deceleration * delta
		if yv < 0:
			yv = 0
		velocity.y = signf(velocity.y) * yv

	return velocity



#endregion
