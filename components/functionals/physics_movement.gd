## apply forces to the attached physics node
@icon("res://components/functionals/physics_movement.png")
class_name PhysicsMovementComponent
extends Node


#region SIGNALS

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
var _target_actor: Actor
var _current_target_pos: Vector2 = Vector2.ZERO
## whether to update _current_target_pos to targets current position
var _is_following_target_actor: bool = false
## max movement speed. with max_speed < accel < deccel we can get some random sidewinding movement,
## but still hit target. with move_speed >= accel we move straight to target
var max_speed: float
## how quickly we accelerate. uses delta, so will apply ~1/60th per frame to the velocity,
## up to max_speed.
var acceleration: float
## how quickly we decelerate. uses delta, so will apply ~1/60th per frame to the velocity.
## applied when max_speed is hit. should be >= acceleration.
var deceleration: float
## whether setup() has been called
var _has_run_setup: bool = false
#endregion


#region FUNCS
func setup(max_speed_: float, acceleration_: float, deceleration_: float) -> void:
	max_speed = max_speed_
	acceleration = acceleration_
	deceleration = deceleration_

	_has_run_setup = true

# TODO: eventually, this should just be the _physics process, so that it doesnt need to be called.
## update the physics state's velocity. won't run until setup() has been called.
func execute_physics(delta: float) -> void:
	if not _has_run_setup:
		return

	## calc direction to target
	if _target_actor is Actor or _current_target_pos != Vector2.ZERO:

		# get or update target position
		if _is_following_target_actor or _current_target_pos == Vector2.ZERO:
			_current_target_pos = _target_actor.global_position

	var velocity = _root.linear_velocity
	var movement = _root.global_position.direction_to(_current_target_pos)

	# if already at max speed, slow down
	var slow_down_force: Vector2 = Vector2.ZERO
	if absf(velocity.x) > max_speed:
		if velocity.x > 0:
			slow_down_force.x -= deceleration
		else:
			slow_down_force.x += deceleration

	if absf(velocity.y) > max_speed:
		if velocity.y > 0:
			slow_down_force.y -= deceleration
		else:
			slow_down_force.y += deceleration

	# apply slowdown, if needed
	if not slow_down_force.is_zero_approx():
		_root.apply_impulse(slow_down_force * delta, _root.global_position)

	# move towards target
	_root.apply_impulse(movement * acceleration * delta, _root.global_position)

# TODO: remove and fold into physics process/execute physics above, so projecitle and actor use same
func calc_movement(state: PhysicsDirectBodyState2D) -> void:
	var velocity: Vector2 = state.get_linear_velocity()
	var step: float = state.get_step()

	# get player input.
	if is_attached_to_player:
		velocity = _apply_input_movement_velocity(velocity, step)

	# apply gravity and set back the linear velocity.
	velocity += state.get_total_gravity() * step
	state.set_linear_velocity(velocity)

func set_target_actor(actor: Actor, is_following: bool) -> void:
	_target_actor = actor
	_is_following_target_actor = is_following

# FIXME: The below is still used by player for movement. Can't get it to work for projectiles.
# 		need to unify approach.
## amends given velocity by input and returns amended velocity
func _apply_input_movement_velocity(velocity: Vector2, delta: float) -> Vector2:
	var move_left := Input.is_action_pressed(&"move_left")
	var move_right := Input.is_action_pressed(&"move_right")
	var move_up := Input.is_action_pressed(&"move_up")
	var move_down := Input.is_action_pressed(&"move_down")

	return _get_velocity(velocity, delta, move_left, move_right, move_up, move_down)

func _get_velocity(velocity: Vector2, delta: float, move_left: bool, move_right: bool, move_up: bool, move_down: bool) -> Vector2:

	if move_left and not move_right:
		if velocity.x > -max_speed:
			velocity.x -= acceleration * delta
	elif move_right and not move_left:
		if velocity.x < max_speed:
			velocity.x += acceleration * delta
	else:
		var xv := absf(velocity.x)
		xv -= deceleration * delta
		if xv < 0:
			xv = 0
		velocity.x = signf(velocity.x) * xv

	# up down
	if move_up and not move_down:
		if velocity.y > -max_speed:
			velocity.y -= acceleration * delta
	elif move_down and not move_up:
		if velocity.y < max_speed:
			velocity.y += acceleration * delta
	else:
		var yv := absf(velocity.y)
		yv -= deceleration * delta
		if yv < 0:
			yv = 0
		velocity.y = signf(velocity.y) * yv

	return velocity



#endregion
