## interface for all boons and banes, aka status effects. handles linking the boonbane to the relevant signals.
@icon("res://components/containers/boon_bane_container.png")
class_name BoonBaneContainer
extends Node


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
@export_group("Component Links")
@export var _root: CombatActor
## needed to connect signals to death triggers
@export var _death_trigger: DeathTrigger
#endregion


#region VARS
## internal dict of the boon banes, by trigger
## Constants.TRIGGER : Array[]
var _boons_banes: Dictionary = {}
## list of all boon banes
## dynamically built on request
var _all_boon_banes: Array[ABCBoonBane]:
	set(value):
		push_warning("BoonsBanesContainerComponent: Can't set _all_boon_banes directly.")
	get:
		# TODO: use a dirty flag to prevent rebuilding unnecessarily
		var all: Array[ABCBoonBane] = []
		for boon_bane_array in _boons_banes.values():
			for boon_bane in boon_bane_array:
				if is_instance_valid(boon_bane):
					all.append(boon_bane)
		return all
#endregion


#region FUNCS
func _ready() -> void:
	# check required values
	assert(
		_root is CombatActor,
		str(
			"BoonsBanesContainerComponent: _root isnt assigned so won't know who ",
			"to apply affects to."
		)
	)

	# init blank dict of arrays
	for trigger in Constants.TRIGGER.values():
		_boons_banes[trigger] = []

## adds a boon bane, if one doesnt exist, otherwise adds the number of stacks to the existing
## boon bane
func add_boon_bane(
	boon_bane_type: Constants.BOON_BANE_TYPE,
	caster: CombatActor,
	num_stacks: int = 1
	) -> void:
	var boon_bane: ABCBoonBane = null

	if boon_bane_type == Constants.BOON_BANE_TYPE.chilled:
		breakpoint

	# find existing
	var found_existing: bool = false
	for existing_boon_bane in _all_boon_banes:
		if boon_bane_type == existing_boon_bane.type:
			boon_bane = existing_boon_bane
			found_existing = true
			break

	if found_existing == false:
		boon_bane = Factory.create_boon_bane(boon_bane_type, self, _root, caster)
		_boons_banes[boon_bane.trigger].append(boon_bane)
		_link_signals_to_triggers(boon_bane)

	# add required stacks
	boon_bane.add_stacks_and_refresh_duration(num_stacks)

	# trigger activation
	if boon_bane.trigger == Constants.TRIGGER.on_application:
		boon_bane.activate(_root)

func remove_boon_bane(boon_bane: ABCBoonBane, ignore_permanent: bool = false) -> void:
	if boon_bane._duration_type == Constants.DURATION_TYPE.permanent and not ignore_permanent:
		push_warning(
			"BoonsBanesContainerComponent: can't remove a permanent boon_bane unless",
			"ignore_permanent is set to true."
		)
		return

	_boons_banes[boon_bane.trigger].erase(boon_bane)
	boon_bane.terminate()

## link the relevant signals, from linked components, to the boonbane, based on its trigger
##
## time based triggering is handled within the [ABCBoonBane]
func _link_signals_to_triggers(boon_bane: ABCBoonBane) -> void:
	match  boon_bane.trigger:
		Constants.TRIGGER.on_death:
			_death_trigger.died.connect(boon_bane.activate)

		Constants.TRIGGER.on_hit_received:
			# TODO: implement
			pass

		Constants.TRIGGER.on_application:
			# activated immediately when added
			pass

		Constants.TRIGGER.on_interval:
			# handled within boon_bane by timer
			pass

		_:
			push_error(
				"BoonsBanesContainerComponent: `_link_signals_to_triggers` given a trigger (",
				Utility.get_enum_name(Constants.TRIGGER, boon_bane.trigger),
				") that we don't know how to handle."
			)

func get_all_boon_banes() -> Array[ABCBoonBane]:
	return _all_boon_banes




#endregion
