## class desc
#@icon("")
class_name CombatPassiveContainer
extends Node2D


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
@export_group("Component Links")
## who created this active
@export var _root: Actor

#endregion


#region VARS
var _passives: Array[ABCCombatPassive] = []
#endregion


#region FUNCS
func _ready() -> void:
	# check for mandatory properties set in editor
	assert(_root is Actor, "Misssing `_root`.")

## link the relevant signals, from linked components, to 
func _link_signals_to_triggers() -> void:

	_root.died.connect(func(deceased): _activate_passives(Constants.TRIGGER.on_death, deceased))

## activate all passives that have the trigger
func _activate_passives(trigger: Constants.TRIGGER, target: Actor, source: Actor = null):
	for p in _passives:
		p.activate(trigger, target, source)


# TODO: add passives 
#       link effects to relevant calls



#endregion
