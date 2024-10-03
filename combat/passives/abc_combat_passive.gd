## class desc
@icon("res://shared_assets/node_icons/abc.png")
class_name ABCCombatPassive
extends Node2D


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
# @export_group("Component Links")
# ## who created this active
# @export var _root: Actor
#endregion


#region VARS

## { Constants.TRIGGER: [ABCEffectChain]}
var _effect_chains: Dictionary = {}
var combat_passive_name: String = ""
var _caster: Actor
## {Actor: time_remaining as float}
var _recent_applications: Dictionary = {}

#endregion


#region FUNCS

##########################
####### LIFECYCLE #######
########################

func _ready() -> void:
	# init blank dict of arrays
	for trigger in Constants.TRIGGER.values():
		_effect_chains[trigger] = []


func setup(combat_passive_name_: String, caster: Actor) -> void:
	combat_passive_name = combat_passive_name_
	_caster = caster

	_load_effect_chains()

func _process(delta: float) -> void:
	# reduce reapplication cooldowns
	var to_delete: Array[Actor] = []
	for a in _recent_applications:
		_recent_applications[a] -= delta
		if _recent_applications[a] <= 0.0:
			to_delete.append(a)

	# delete expired cooldowns
	for a in to_delete:
		_recent_applications.erase(a)

func activate(trigger: Constants.TRIGGER, target: Actor, source: Actor = null) -> bool:
	# check if we have recently applied to target
	if target in _recent_applications:
		return false

	# define the source
	var source_: Actor
	if source is Actor:
		source_ = source
	else:
		source_ = _caster
	
	# get effects
	var effect_chains: Array[ABCEffectChain] = _effect_chains[trigger]

	# apply the effect chains
	for e in effect_chains:
		e.apply(target, source_)

	return true

##########################
####### PRIVATE #########
########################

func _load_effect_chains() -> void:
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
	

#endregion
