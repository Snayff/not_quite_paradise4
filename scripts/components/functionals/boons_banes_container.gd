## interface for all boons and banes, aka status effects. handles linking the boonbane to the relevant signals.
@icon("res://assets/node_icons/status_effects.png")
class_name BoonsBanesContainerComponent
extends Node


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
@export_category("Component Links")
@export var death_trigger: DeathTrigger
#
# @export_category("Details")  # feel free to rename category
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
	_boons_banes[trigger].append(boon_bane)
	_link_signals_to_triggers(boon_bane)

func remove_boon_bane(boon_bane: BoonBane, trigger: Constants.TRIGGER) -> void:
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
