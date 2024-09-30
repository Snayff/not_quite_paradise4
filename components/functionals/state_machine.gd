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
## used when [member _is_debug] is true.
var _announced: bool = false
#endregion


#region FUNCS
func _ready() -> void:
	_state_machine = LimboHSM.new()
	add_child(_state_machine)

## create the states and setup the transitions
func init_state_machine() -> void:
	# create states
	var idle_state = LimboState.new() \
		.named("idle") \
		.call_on_enter(_idle_start) \
		.call_on_update(_idle_update)
	var walk_state = LimboState.new() \
		.named("walk") \
		.call_on_enter(_walk_start) \
		.call_on_update(_walk_update)
	var cast_state = LimboState.new() \
		.named("cast") \
		.call_on_enter(_cast_start) \
		.call_on_update(_cast_update)
	var dead_state = LimboState.new() \
		.named("dead") \
		.call_on_enter(_dead_start) \
		.call_on_update(_dead_update)

	# add states to state machine
	_state_machine.add_child(idle_state)
	_state_machine.add_child(walk_state)
	_state_machine.add_child(cast_state)
	_state_machine.add_child(dead_state)

	# define initial state
	_state_machine.initial_state = idle_state

	# define possible transitions
	_state_machine.add_transition(idle_state, walk_state, &"to_walk")
	_state_machine.add_transition(_state_machine.ANYSTATE, idle_state, &"to_idle")
	_state_machine.add_transition(_state_machine.ANYSTATE, cast_state, &"to_cast")
	_state_machine.add_transition(_state_machine.ANYSTATE, dead_state, &"to_dead")

	# init and activate state machine
	_state_machine.initialize(self)
	_state_machine.set_active(true)

func _idle_start() -> void:
	if _is_debug:
		print("Entered idle start")

	_sprite.play("idle")

func _idle_update(_delta: float) -> void:
	if _is_debug:
		if _announced == false:
			print("Entered idle update.")
			_announced = true

	if not _root.linear_velocity.is_zero_approx():
		_state_machine.dispatch(&"to_walk")
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

	if _root.linear_velocity.is_zero_approx():
		_state_machine.dispatch(&"to_idle")
		_announced = false
	else:
		_flip_sprite()

func _cast_start() -> void:
	if _is_debug:
		print("Entered cast start")

	_sprite.play("cast_full")

func _cast_update(_delta: float) -> void:
	if _is_debug:
		if _announced == false:
			print("Entered cast update")
			_announced = true

func _dead_start() -> void:
	if _is_debug:
		print("Entered dead start")

	_sprite.play("die")

func _dead_update(_delta: float) -> void:
	if _is_debug:
		if _announced == false:
			print("Entered dead update")
			_announced = true

## flips _sprite based on [member _root].[member linear_velocity]
func _flip_sprite() -> void:
	if _root.linear_velocity.x > 0:
		_sprite.flip_h = false
	elif _root.linear_velocity.x < 0:
		_sprite.flip_h = true



#endregion
