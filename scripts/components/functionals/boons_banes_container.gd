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
@export var death_trigger: DeathTrigger
#
# @export_group("Details")  # feel free to rename category
#endregion


#region VARS
var _boons_banes: Dictionary = {}  ## Constants.TRIGGER : Array[]
#endregion


#region FUNCS
func _ready() -> void:
	# init blank dict of arrays
	for trigger in Constants.TRIGGER.values():
		_boons_banes[trigger] = []

func add_boon_bane(boon_bane: BoonBane, trigger: Constants.TRIGGER) -> void:
	# if unique, check for any existing of same class
	if boon_bane.is_unique:
		for boon_bane_ in _boons_banes:
			if boon_bane_.get_script().resource_path == boon_bane.get_script().resource_path:
				return

	_boons_banes[trigger].append(boon_bane)
	_link_signals_to_triggers(boon_bane)

func remove_boon_bane(boon_bane: BoonBane, trigger: Constants.TRIGGER, ignore_permanent: bool = false) -> void:
	if boon_bane.duration_type == Constants.DURATION_TYPE.permanent and not ignore_permanent:
		push_warning("BoonsBanesContainerComponent: can't remove a permanent boon_bane unless ignore_permanent is set to true.")
		return

	_boons_banes[trigger].erase(boon_bane)
	boon_bane.queue_free()

## link the relevant signals, from linked components, to the boonbane, based on its trigger
func _link_signals_to_triggers(boon_bane: BoonBane) -> void:
	match  boon_bane.trigger:
		Constants.TRIGGER.on_death:
			death_trigger.died.connect(boon_bane.activate)

		Constants.TRIGGER.on_hit_received:
			# TODO: add
			pass






#endregion
