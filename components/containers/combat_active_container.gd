## interface for a collection of [CombatActive]s.
##
## better to use this over interacting with the [CombatActive]s directly.
@icon("res://components/containers/combat_active_container.png")
class_name CombatActiveContainer
extends Node2D


const _COMBAT_ACTIVE: PackedScene = preload("res://combat/actives/combat_active.tscn")

#region SIGNALS
signal active_became_ready
signal new_active_selected(active: CombatActive)
signal new_target(target: Actor)
#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
@export_group("Component Links")
## who created this active
@export var _root: Actor
## creator's allegiance component
@export var _allegiance: Allegiance
##  delivery method's spawn location. Ignored by Orbital.
@export var _cast_position: Marker2D
## the supplies to be used to cast actives
@export var _supplies: SupplyContainer
@export_group("Details")
## list of names of the combat actives. used on init to instantiate the names given as nodes.
@export var _combat_active_names: Array[String] = []
#endregion


#region VARS
## all combat actives.
var _actives: Array[CombatActive]:
	set(value):
		_actives = value
## actives that are ready to cast - may not have a target.
var _ready_actives: Array[CombatActive] = []
# NOTE: the selection things might be better elsewhere, in a control node
## the currently selected index in _active.
var _selection_index: int = 0
## the active selected. determined by _selection_index
var selected_active: CombatActive:
	set(_x):
		push_error("CombatActiveContainer: Cannot set selected_active directly.")
	get():
		if not _actives.is_empty():
			return _actives[_selection_index]
		else:
			return null
var has_ready_active: bool:
	set(_x):
		push_error("CombatActiveContainer: Cannot set has_ready_active directly.")
	get():
		if _ready_actives.size() > 0:
			return true
		else:
			return false
#endregion


#region FUNCS
func _ready() -> void:
	# check for mandatory properties set in editor
	assert(_root is Actor, "Misssing `_root`.")
	assert(_allegiance is Allegiance, "Misssing `_allegiance`.")
	assert(_cast_position is Marker2D, "Misssing `_cast_position`.")
	assert(_supplies is SupplyContainer, "Misssing `_supplies`.")

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

## create [CombatActive]s from names. Runs setup and connects to
## signals.
##
## Only adds new actives, so does not clear existing.
func create_actives(combat_active_names_: Array[String]) -> void:
	for name_ in combat_active_names_:

		# ensure we dont create one that already exists
		for a in _actives:
			if name_ == a.combat_active_name:
				continue

		# create active and take note
		var active_: CombatActive = _COMBAT_ACTIVE.instantiate()
		add_child(active_)
		_actives.append(active_)

		# setup active
		active_.setup(name_, _root, _allegiance, _cast_position)

		# connect to signals
		active_.now_ready.connect(func(): _ready_actives.append(active_))
		active_.now_ready.connect(active_became_ready.emit)
		active_.was_cast.connect(func(): _ready_actives.erase(active_))

	# if we have a selected active already, connect to its target signal
	if selected_active:
		selected_active.new_target.connect(_emit_new_target)

## emit the new_target signal
##
## N.B. using func over lambda so we can disconnect when swapping selected active
func _emit_new_target(target: Actor) -> void:
	new_target.emit(target)

## get an active by its class_name. returns null if nothing matching found.
func get_active(active_name: String) -> CombatActive:
	for active in _actives:
		if active.combat_active_name == active_name:
			return active

	return null

## get all actives
func get_all_actives() -> Array[CombatActive]:
	return _actives

## @nullable. picks a random, ready active.
##
## returns null if no active is ready.
func get_random_ready_active() -> CombatActive:
	if _ready_actives.size() > 0:
		var random_active: CombatActive = _ready_actives.pick_random()
		return random_active
	return null

## picks a random, ready active and casts it, if there is a target.
## If no target, nothing happens. returns true if successfully cast.
func cast_random_ready_active() -> bool:
	var random_active: CombatActive = get_random_ready_active()
	if random_active is CombatActive:
		return cast_ready_active(random_active.name)

	else:
		return false

## casts the specified active, if it is ready and there is a target.
## If not, nothing happens.returns true if successfully cast.
func cast_ready_active(active_name: String) -> bool:
	var active: CombatActive = get_active(active_name)
	if active.can_cast:
		# pay the toll
		var supply: SupplyComponent = _supplies.get_supply(active.cast_supply)
		# only health supply MUST have enough to use
		if active.cast_supply == Constants.SUPPLY_TYPE.health:
			if active.cast_cost > supply.value:
				# not enough health to afford casting. actor would die
				return false

		# for any supply other than health, just drain the amount
		supply.decrease(active.cast_cost)

		# cast the active
		active.cast()

		# confirm positive result
		return true

	return false

## get the smallest and largest ranges of all combat actives.
##
## [smallest, largest]
func get_ranges() -> Array[float]:
	var smallest: float = 0.0
	var largest: float = 0.0
	for active in get_all_actives():
		var active_range: float = active.get_range()
		if smallest == 0.0 or active_range < smallest:
			smallest = active_range
		if largest == 0.0 or active_range > largest:
			largest = active_range

	return [smallest, largest]







#endregion
