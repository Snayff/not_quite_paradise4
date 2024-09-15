## apply forces to the attached physics node
@icon("res://components/functionals/phys_move.png")
class_name PhysicsMovementComponent
extends Node


# TODO: move these to a stat sheet, as they vary by actor
const WALK_ACCEL = 1000.0
const WALK_DEACCEL = 1000.0
const WALK_MAX_VELOCITY = 200.0


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
@export_group("Component Links")
## the body to apply forces to
@export var _root: PhysicsBody2D
## the sprite we're going to flip the facing of, based on direction
@export var _sprite: Node2D
@export_group("Details")
## divert logic to respond to controls rather than targeting
@export var is_attached_to_player: bool = false
#endregion


#region VARS
var _is_facing_left: bool = false
var _target_actor: CombatActor
var _current_target_pos: Vector2 = Vector2.ZERO
## whether to update _current_target_pos to targets current position
var _is_following_target_actor: bool = false
## max movement speed. with max_speed < accel < deccel we can get some random sidewinding movement,
## but still hit target. with move_speed >= accel we move straight to target
var _max_speed: float
## how quickly we accelerate. uses delta, so will apply ~1/60th per frame to the velocity,
## up to max_speed.
var _acceleration: float
## how quickly we decelerate. uses delta, so will apply ~1/60th per frame to the velocity.
## applied when max_speed is hit. should be >= acceleration.
var _deceleration: float
## whether setup() has been called
var _has_run_setup: bool = false
#endregion


#region FUNCS
func setup(max_speed: float, acceleration: float, deceleration: float) -> void:
	_max_speed = max_speed
	_acceleration = acceleration
	_deceleration = deceleration

	_has_run_setup = true

# TODO: eventually, this should just be the _physics process, so that it doesnt need to be called.
## update the physics state's velocity. won't run until setup() has been called.
func execute_physics(delta: float) -> void:
	if not _has_run_setup:
		return

	## calc direction to target
	if _target_actor is CombatActor or _current_target_pos != Vector2.ZERO:

		# get or update target position
		if _is_following_target_actor or _current_target_pos == Vector2.ZERO:
			_current_target_pos = _target_actor.global_position

	var velocity = _root.linear_velocity
	var movement = _root.global_position.direction_to(_current_target_pos)

	# if already at max speed, slow down
	var slow_down_force: Vector2 = Vector2.ZERO
	if absf(velocity.x) > _max_speed:
		if velocity.x > 0:
			slow_down_force.x -= _deceleration
		else:
			slow_down_force.x += _deceleration

	if absf(velocity.y) > _max_speed:
		if velocity.y > 0:
			slow_down_force.y -= _deceleration
		else:
			slow_down_force.y += _deceleration

	# apply slowdown, if needed
	if not slow_down_force.is_zero_approx():
		_root.apply_impulse(slow_down_force * delta, _root.global_position)

	# move towards target
	_root.apply_impulse(movement * _acceleration * delta, _root.global_position)

# TODO: remove and fold into physics process/execute physics above, so projecitle and actor use same
func calc_movement(state: PhysicsDirectBodyState2D) -> void:
	var velocity: Vector2 = state.get_linear_velocity()
	var step: float = state.get_step()

	# get player input.
	if is_attached_to_player:
		velocity = _apply_input_movement_velocity(velocity, step)

	# TODO: only amend facing if we intend to move in a direction. e.g. dont face direction
	#	because knocked back in that direction.
	_amend_facing(velocity, velocity.x < 0, velocity.x > 0)

	# apply gravity and set back the linear velocity.
	velocity += state.get_total_gravity() * step
	state.set_linear_velocity(velocity)

func set_target_actor(actor: CombatActor, is_following: bool) -> void:
	_target_actor = actor
	_is_following_target_actor = is_following

## amend the attached sprites facing based on movement and velocity
func _amend_facing(velocity: Vector2, move_left: bool, move_right: bool) -> void:
	# FIXME: this is no longer working
	if !is_instance_valid(_sprite):
		return

	var new_facing_left: bool = _is_facing_left

	# Check facing
	if velocity.x < 0 and move_left:
		new_facing_left = true
	elif velocity.x > 0 and move_right:
		new_facing_left = false

	# Update facings
	if new_facing_left != _is_facing_left:
		if new_facing_left:
			# some nodes just need the x axis flipping
			_sprite.scale.x = -1

			# but some nodes need their relative position flipping, too
			if _sprite.position.x != 0:
				_sprite.position.x = _sprite.position.x * -1
		else:
			_sprite.scale.x = 1

			if _sprite.position.x != 0:
				_sprite.position.x = _sprite.position.x * -1

	_is_facing_left = new_facing_left

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



#endregion
