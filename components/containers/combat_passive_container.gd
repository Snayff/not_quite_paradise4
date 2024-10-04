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

	_link_signals_to_triggers()


func create_passives(combat_passive_names: Array[String]) -> void:
	@warning_ignore("unused_variable")  # godot things dict_data isnt used for some reason
	var dict_data: Dictionary = {}
	var passive: ABCCombatPassive = null
	for passive_name in combat_passive_names:
		dict_data = Library.get_data("combat_passive", passive_name)

		# load the script
		passive = load(
			Constants.PATH_COMBAT_PASSIVES.path_join(
				str("combat_passive_", passive_name, ".gd")
			)
		).new()

		# add the script
		add_child(passive)
		_passives.append(passive)

		# run setup
		passive.setup(passive_name, _root)

## link the relevant signals, from linked components, to `_activate_passives` and build a
## [DataCombatPassive]
func _link_signals_to_triggers() -> void:

	# Constants.TRIGGER.on_death
	_root.died.connect(
		func(deceased): \
		_activate_passives(
			DataCombatPassive.new().define(deceased, Constants.TRIGGER.on_death)
		)
	)

	# Constants.TRIGGER.on_receive_damage
	_root.received_damage.connect(
		func(who, amount): \
		_activate_passives(
			DataCombatPassive.new() \
			.define(who, Constants.TRIGGER.on_receive_damage) \
			.define_receive_damage(amount)
		)
	)

## activate all passives that have the trigger
func _activate_passives(data: DataCombatPassive):
	for p in _passives:
		p.activate(data)


#endregion
