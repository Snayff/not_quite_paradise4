## interface for a collection of [CombatActive] scenes.
##
## CombatActives should be added as instantiated scene children.
@icon("res://components/containers/combat_active_container.png")
class_name CombatActiveContainer
extends Node2D


const _COMBAT_ACTIVE: PackedScene = preload("res://combat/actives/combat_active.tscn")

#region SIGNALS
signal has_ready_active
signal new_active_selected(active: CombatActive)
signal new_target(target: Actor)
#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
@export_group("Component Links")
@export var _root: Actor  ## who created this active
@export var _allegiance: Allegiance  ## creator's allegiance component
@export var _cast_position: Marker2D  ##  delivery method's spawn location. Ignored by Orbital.
@export var _supplies: SupplyContainer  ## the supplies to be used to cast actives
@export_group("Details")
## list of names of the combat actives. used on init to instantiate the names given as nodes.
@export var _combat_active_names: Array[String] = []
#endregion


#region VARS
var _actives: Array[CombatActive]:  ## all combat actives.
	set(value):
		_actives = value
var _ready_actives: Array[CombatActive]  ## actives that are ready to cast - may not have a target.
# NOTE: the selection things might be better elsewhere, in a control node
var _selection_index: int = 0  ## the currently selected index in _active.
var selected_active: CombatActive:
	set(_x):
		push_error("CombatActiveContainer: Cannot set selected_active directly.")
	get():
		if not _actives.is_empty():
			return _actives[_selection_index]
		else:
			return null
#endregion


#region FUNCS
func _ready() -> void:
	# check for mandatory properties set in editor
	assert(_root is Actor, "Misssing `_root`.")
	assert(_allegiance is Allegiance, "Misssing `_allegiance`.")
	assert(_cast_position is Marker2D, "Misssing `_cast_position`.")
	assert(_supplies is SupplyContainer, "Misssing `_supplies`.")

	_create_actives()

	# select first active
	if _actives.size() > 0:
		_actives[0].is_selected = true

func _unhandled_input(_event: InputEvent) -> void:
	var next_active: bool = Input.is_action_just_pressed(&"next_active")
	var cast_active: bool = Input.is_action_just_pressed(&"use_active")

	if next_active and not _actives.is_empty():
		# toggle off and reset
		if selected_active.is_connected("new_target", _emit_new_target):
			selected_active.new_target.disconnect(_emit_new_target)
		selected_active.is_selected = false

		# update index and toggle on
		_selection_index = (_selection_index + 1) % _actives.size()  # wrap around
		new_active_selected.emit(selected_active)
		selected_active.new_target.connect(_emit_new_target)
		selected_active.is_selected = true

	elif cast_active and selected_active != null:
		cast_ready_active(selected_active.name)

## use actives for which we have names in [_combat_active_names]. Runs setup and connects to
## signals.
func _create_actives() -> void:
	for name_ in _combat_active_names:
		# create active and take note
		var active_: CombatActive = _COMBAT_ACTIVE.instantiate()
		add_child(active_)
		_actives.append(active_)

		# setup active
		active_.setup(name_, _root, _allegiance, _cast_position)

		# connect to signals
		active_.now_ready.connect(func(): _ready_actives.append(active_))
		active_.now_ready.connect(has_ready_active.emit)

	# if we have a selected active already, connect to its target signal
	if selected_active:
		selected_active.new_target.connect(_emit_new_target)


	for child in get_children():
		if child is CombatActive:
			_actives.append(child)

## emit the new_target signal
##
## N.B. using func over lambda so we can disconnect when swapping selected active
func _emit_new_target(target: Actor) -> void:
	new_target.emit(target)

## get an active by its class_name. returns null if nothing matching found.
func get_active(active_name: String) -> CombatActive:
	for active in _actives:
		if active.name == active_name:
			return active

	return null

## get all actives
func get_all_actives() -> Array[CombatActive]:
	return _actives

## picks a random, ready active and casts it, if there is a target. If no target, nothing happens. returns true if successfully cast.
func cast_random_ready_active() -> bool:
	if _ready_actives.size() > 0:
		var random_active: CombatActive = _ready_actives.pick_random()
		return cast_ready_active(random_active.name)

	else:
		push_warning("CombatActiveContainer: No ready combat active.")
		return false

## casts the specified active, if it is ready and there is a target. If not, nothing happens.returns true if successfully cast.
func cast_ready_active(active_name: String) -> bool:
	var active: CombatActive = get_active(active_name)
	if active.can_cast:
		# pay the toll
		var supply: Supply = _supplies.get_supply(active.cast_supply)
		# only health supply MUST have enough to use
		if active.cast_supply == Constants.SUPPLY_TYPE.health:
			if active.cast_cost > supply.value:
				# not enough health to afford casting. actor would die
				return false

		# for any supply other than health, just drain the amount
		supply.decrease(active.cast_cost)

		# cast the active
		active.cast()

		# remove from list of actives
		_ready_actives.erase(active)

		# confirm positive result
		return true

	return false








#endregion
