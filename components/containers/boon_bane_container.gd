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
@export var _root: Actor
@export var _death_trigger: DeathTrigger  ## needed to connect signals to death triggers
#
# @export_group("Details")  # feel free to rename category
#endregion


#region VARS
var _boons_banes: Dictionary = {}  ## Constants.TRIGGER : Array[]
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
	assert(_root is Actor, "BoonsBanesContainerComponent: _root isnt assigned so won't know who to apply affects to.")

	# init blank dict of arrays
	for trigger in Constants.TRIGGER.values():
		_boons_banes[trigger] = []

func add_boon_bane(boon_bane: ABCBoonBane) -> void:
	# if unique, check for any existing of same class
	if boon_bane.is_unique:
		for boon_bane_ in _all_boon_banes:
			if boon_bane_.get_script().resource_path == boon_bane.get_script().resource_path:
				return

	add_child(boon_bane)
	_boons_banes[boon_bane.trigger].append(boon_bane)
	_link_signals_to_triggers(boon_bane)
	boon_bane.host = _root

func remove_boon_bane(boon_bane: ABCBoonBane, ignore_permanent: bool = false) -> void:
	if boon_bane.duration_type == Constants.DURATION_TYPE.permanent and not ignore_permanent:
		push_warning("BoonsBanesContainerComponent: can't remove a permanent boon_bane unless ignore_permanent is set to true.")
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
			# activated immediately in boon_bane
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
