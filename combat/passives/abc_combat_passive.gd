## reactions to the game world
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
var f_name: String = ""
## list of triggers used by class
## defined in subclass
var _triggers_used: Array[Constants.TRIGGER] = []
var _caster: Actor
## {Actor: time_remaining as float}
var _recent_applications: Dictionary = {}
## { Constants.TRIGGER: Callable }
var _trigger_method_map: Dictionary = {}
## how long to wait between activations.
##
## never less than the trigger delay Constants.PASSIVE_TRIGGER_DELAY
var _cooldown: float = 0.0
## tracking time of current cooldown
var _cooldown_countdown: float = 0.0
#endregion


#region FUNCS

##########################
####### LIFECYCLE #######
########################

func _ready() -> void:
	# init map of trigger to method
	for trigger in Constants.TRIGGER.values():
		var callable: Callable
		match trigger:
			Constants.TRIGGER.on_death:
				callable = _on_death

			Constants.TRIGGER.on_receive_damage:
				callable = _on_receive_damage

			_:
				pass

		_trigger_method_map[trigger] = callable

func setup(data: DataCombatPassive, caster: Actor) -> void:
	f_name = data.f_name
	_cooldown = max(data.cooldown, Constants.PASSIVE_TRIGGER_DELAY)

	_caster = caster

func _process(delta: float) -> void:
	# reduce internal cooldown
	_cooldown_countdown -= delta

	# reduce reapplication cooldowns
	var to_delete: Array[Actor] = []
	for a in _recent_applications:
		_recent_applications[a] -= delta
		if _recent_applications[a] <= 0.0:
			to_delete.append(a)

	# delete expired cooldowns
	for a in to_delete:
		_recent_applications.erase(a)

## activate the passive.
##
## can fail if target has been affected recently, if trigger in data
## isnt in [member _triggers_used], or [member _cooldown_countdown] is still counting down
func activate(data: DataCombatPassiveActivation) -> bool:
	# check for internal cooldown
	if _cooldown_countdown > 0:
		return false

	# check if we have recently applied to target
	if data.target in _recent_applications:
		return false

	# ignore calls to triggers we dont make use of
	if data.trigger not in _triggers_used:
		return false

	# call relevant method
	_trigger_method_map[data.trigger].call(data)

	# set internal cooldown
	_cooldown_countdown = _cooldown

	return true

##########################
####### PRIVATE #########
########################


## @virtual. actions to trigger when passive receives Constants.TRIGGER.on_death
@warning_ignore("unused_parameter")  # is virtual
func _on_death(data: DataCombatPassiveActivation) -> void:
	push_error(
		"ABCCombatPassive: `_on_death` called directly, but is virtual. Must be overriden by child."
	)

## @virtual. actions to trigger when passive receives Constants.TRIGGER.on_receive_damage
@warning_ignore("unused_parameter")  # is virtual
func _on_receive_damage(data: DataCombatPassiveActivation) -> void:
	push_error(
		"ABCCombatPassive: `_on_receive_damage` called directly, but is virtual. Must be overriden by child."
	)

#endregion