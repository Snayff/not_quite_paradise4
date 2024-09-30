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
	var attack_state = LimboState.new() \
		.named("attack") \
		.call_on_enter(_attack_start) \
		.call_on_update(_attack_update)

	# add states to state machine
	_state_machine.add_child(idle_state)
	_state_machine.add_child(walk_state)
	_state_machine.add_child(attack_state)

	_state_machine.initial_state = idle_state

	_state_machine.add_transition(idle_state, walk_state, &"to_walk")
	_state_machine.add_transition(_state_machine.ANYSTATE, idle_state, &"to_idle")
	_state_machine.add_transition(_state_machine.ANYSTATE, attack_state, &"to_attack")

	# init and activate state machine
	_state_machine.initialize(self)
	_state_machine.set_active(true)

## debug - announced state
var announced: bool = false

func _idle_start() -> void:
	if _is_debug:
		print("entered idle start")
	_sprite.play("idle")

func _idle_update(delta: float) -> void:
	if _is_debug:
		if announced == false:
			print("entered idle update.")
			announced = true

	if not _root.linear_velocity.is_zero_approx():
		_state_machine.dispatch(&"to_walk")
		announced = false

func _walk_start() -> void:
	if _is_debug:
		print("entered walk start")
	_sprite.play("walk")

func _walk_update(delta: float) -> void:
	if _is_debug:
		if announced == false:
			print("entered walk update")
			announced = true

	if _root.linear_velocity.is_zero_approx():
		_state_machine.dispatch(&"to_idle")
		announced = false
	else:
		_flip_sprite()

func _attack_start() -> void:
	if _is_debug:
		print("entered attack start")


func _attack_update(delta: float) -> void:
	if _is_debug:
		if announced == false:
			print("entered attack update")
			announced = true

## flips _sprite based on [member _root].[member linear_velocity]
func _flip_sprite() -> void:
	if _root.linear_velocity.x > 0:
		_sprite.flip_h = false
	elif _root.linear_velocity.x < 0:
		_sprite.flip_h = true



#endregion
