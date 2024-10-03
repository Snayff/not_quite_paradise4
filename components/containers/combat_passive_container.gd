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


func create_passives(combat_passive_names) -> void:
	# FIXME: get name from lib, load script, add
	var dict_data: Dictionary = Library.get_data("combat_passives", combat_passive_name)

	# loop all listed triggers and load the effect chains
	var effect_chain_script: Script = null
	var effect_chain: ABCEffectChain = null
	for trigger in dict_data["triggers"]:
		for chain_name in dict_data["triggers"]["trigger"]:
			
			# load the script
			effect_chain_script = load(
				Constants.PATH_COMBAT_PASSIVES.path_join(
					str(chain_name, ".gd")
				)
			)

			# create and add the script
			effect_chain = effect_chain_script.new()
			add_child(effect_chain)
			_effect_chains[trigger].append(effect_chain)


## link the relevant signals, from linked components, to 
func _link_signals_to_triggers() -> void:

	_root.died.connect(
		func(deceased): \
		_activate_passives(
			DataCombatPassive.new().define(deceased, Constants.TRIGGER.on_death)
		)
	)
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


# TODO: add passives 
#       link effects to relevant calls



#endregion
