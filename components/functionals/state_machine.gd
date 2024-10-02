## an actor's state machine
@icon("res://components/functionals/state_machine.png")
class_name ActorStateMachine
extends Node


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
@export_group("Component Links")
@export var _root: Actor
@export var _sprite: AnimatedSprite2D
@export_group("Debug")
@export var _is_debug: bool = false
#endregion


#region VARS
var _state_machine: LimboHSM
## flag showing whether a new state has been announced or not
##
## used when [member _is_debug] is true.
var _announced: bool = false
## how long to cast for, i.e. to stay in cast state before using the [CombatActive]
var _cast_duration: float = 0.0
#endregion


#region FUNCS

##########################
####### LIFECYCLE ######
######################

func _ready() -> void:
	_state_machine = LimboHSM.new()
	add_child(_state_machine)

##########################
####### PUBLIC ##########
########################

## create the states and setup the transitions
func init_state_machine() -> void:
	# create states
	var idle_state = LimboState.new() \
		.named("idle") \
		.call_on_enter(_idle_start) \
		.call_on_update(_idle_update) \
		.call_on_exit(_idle_exit)
	var walk_state = LimboState.new() \
		.named("walk") \
		.call_on_enter(_walk_start) \
		.call_on_update(_walk_update) \
		.call_on_exit(_walk_exit)
	var cast_state = LimboState.new() \
		.named("cast") \
		.call_on_enter(_cast_start) \
		.call_on_update(_cast_update) \
		.call_on_exit(_cast_exit)
	var use_active_state = LimboState.new() \
		.named("use_active") \
		.call_on_enter(_use_active_start) \
		.call_on_update(_use_active_update) \
		.call_on_exit(_use_active_exit)
	var dead_state = LimboState.new() \
		.named("dead") \
		.call_on_enter(_dead_start) \
		.call_on_update(_dead_update) \
		.call_on_exit(_dead_exit)

	# add states to state machine
	_state_machine.add_child(idle_state)
	_state_machine.add_child(walk_state)
	_state_machine.add_child(cast_state)
	_state_machine.add_child(use_active_state)
	_state_machine.add_child(dead_state)

	# define initial state
	_state_machine.initial_state = idle_state

	# define possible transitions
	_state_machine.add_transition(idle_state, walk_state, &"to_walk")
	_state_machine.add_transition(_state_machine.ANYSTATE, idle_state, &"to_idle")
	_state_machine.add_transition(idle_state, cast_state, &"to_cast")
	_state_machine.add_transition(walk_state, cast_state, &"to_cast")
	_state_machine.add_transition(cast_state, use_active_state, &"to_use_active")
	_state_machine.add_transition(_state_machine.ANYSTATE, dead_state, &"to_dead")

	# init and activate state machine
	_state_machine.initialize(self)
	_state_machine.set_active(true)

## move to cast state, if in appropriate state (idle, walk)
func to_cast(cast_duration: float) -> void:
	_cast_duration = cast_duration
	_state_machine.dispatch(&"to_cast")

##########################
####### PRIVATE #########
########################

func _idle_start() -> void:
	if _is_debug:
		print("Entered idle start")

	_sprite.play("idle")

func _idle_update(_delta: float) -> void:
	if _is_debug:
		if _announced == false:
			print("Entered idle update.")
			_announced = true

	# move to walking when velocity != 0
	if not _root.linear_velocity.is_zero_approx():
		_state_machine.dispatch(&"to_walk")

func _idle_exit() -> void:
	_announced = false

func _walk_start() -> void:
	if _is_debug:
		print("Entered walk start")

	_sprite.play("walk")

func _walk_update(_delta: float) -> void:
	if _is_debug:
		if _announced == false:
			print("Entered walk update")
			_announced = true

	# move to idle when velocity == 0
	if _root.linear_velocity.is_zero_approx():
		_state_machine.dispatch(&"to_idle")
	else:
		_flip_sprite()

func _walk_exit() -> void:
	_announced = false

func _cast_start() -> void:
	if _is_debug:
		print("Entered cast start")

	_sprite.play("cast_loop")

func _cast_update(delta: float) -> void:
	if _is_debug:
		if _announced == false:
			print("Entered cast update")
			_announced = true

	# countdown cast time
	_cast_duration -= delta
	if _cast_duration <= 0:
		_state_machine.dispatch(&"to_use_active")

func _cast_exit() -> void:
	_announced = false

func _use_active_start() -> void:
	if _is_debug:
		print("Entered use active start")

	_sprite.play("cast_full")

func _use_active_update(_delta: float) -> void:
	if _is_debug:
		if _announced == false:
			print("Entered use active update")
			_announced = true

func _use_active_exit() -> void:
	_announced = false

func _dead_start() -> void:
	if _is_debug:
		print("Entered dead start")

	_sprite.play("die")

func _dead_update(_delta: float) -> void:
	if _is_debug:
		if _announced == false:
			print("Entered dead update")
			_announced = true

func _dead_exit() -> void:
	_announced = false

## flips _sprite based on [member _root].[member linear_velocity]
func _flip_sprite() -> void:
	if _root.linear_velocity.x > 0:
		_sprite.flip_h = false
	elif _root.linear_velocity.x < 0:
		_sprite.flip_h = true



#endregion
