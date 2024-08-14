## interface for all boons and banes, aka status effects. handles linking the boonbane to the relevant signals.
@icon("res://assets/node_icons/status_effects.png")
class_name BoonsBanesContainerComponent
extends Node


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
@export_group("Component Links")
@export var _root: CombatActor
@export var _death_trigger: DeathTrigger
#
# @export_group("Details")  # feel free to rename category
#endregion


#region VARS
var _boons_banes: Dictionary = {}  ## Constants.TRIGGER : Array[]
var _all_boon_banes: Array[BoonBane]:
	set(value):
		push_warning("BoonsBanesContainerComponent: Can't set _all_boon_banes directly.")
	get:
		var all: Array[BoonBane] = []
		for boon_bane_array in _boons_banes.values():
			all.append_array(boon_bane_array)
		return all
#endregion


#region FUNCS
func _ready() -> void:
	# check required values
	assert(_root is CombatActor, "BoonsBanesContainerComponent: _root isnt assigned so won't know who to apply affects to.")

	# init blank dict of arrays
	for trigger in Constants.TRIGGER.values():
		_boons_banes[trigger] = []

func add_boon_bane(boon_bane: BoonBane) -> void:
	# if unique, check for any existing of same class
	if boon_bane.is_unique:
		for boon_bane_ in _all_boon_banes:
			if boon_bane_.get_script().resource_path == boon_bane.get_script().resource_path:
				return
	add_child(boon_bane)
	_boons_banes[boon_bane.trigger].append(boon_bane)
	_link_signals_to_triggers(boon_bane)
	boon_bane.host = _root

func remove_boon_bane(boon_bane: BoonBane, ignore_permanent: bool = false) -> void:
	if boon_bane.duration_type == Constants.DURATION_TYPE.permanent and not ignore_permanent:
		push_warning("BoonsBanesContainerComponent: can't remove a permanent boon_bane unless ignore_permanent is set to true.")
		return

	_boons_banes[boon_bane.trigger].erase(boon_bane)
	boon_bane.queue_free()

## link the relevant signals, from linked components, to the boonbane, based on its trigger
##
## time based triggering is handled within the [BoonBane]
func _link_signals_to_triggers(boon_bane: BoonBane) -> void:
	match  boon_bane.trigger:
		Constants.TRIGGER.on_death:
			_death_trigger.died.connect(boon_bane.activate)

		Constants.TRIGGER.on_hit_received:
			# TODO: add
			pass






#endregion
