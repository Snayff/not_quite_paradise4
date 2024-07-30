## abc for a series of effects
@icon("res://assets/node_icons/effect_chain.png")
class_name EffectChain
extends Node


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_category("Component Links")
# @export var
#
@export_category("Details")
@export var caster_required_tags: Array[Constants.COMBAT_TAG] = []  ## tags the caster must have to be able to activate
@export var target_required_tags: Array[Constants.COMBAT_TAG] = []  ## tags the target must have to be able to effect
#endregion


#region VARS
var caster: CombatActor
var _active_effects: Array[Effect] = []  ## an array of all active effects. Each effect needs to be removed when terminated.
var _startup_allowance: float = 5.0  ## time to allow effects to be added to the effect chain, so that we dont clean up too early
#endregion


#region FUNCS
func _process(delta: float) -> void:
	_startup_allowance -= delta
	if len(_active_effects) == 0 and _startup_allowance <= 0:
		_terminate()

########### ACTIVATIONS ############
## check the conditions to activate are met
##
## this is usually casting, but can be activated by other means.
func can_activate() -> bool:
	var tags = caster.get_node_or_null("Tags")
	if tags is TagsComponent:
		return tags.has_tags(caster_required_tags)
	return false

## activate the chain of effects.
##
## this is usually casting, but can be activated by other means.
func activate() -> void:
	pass

func on_activate() -> void:
	pass

func on_hit(hurtbox: HurtboxComponent) -> void:
	pass

## register an effect with the internals, for automated cleanup
func _register_effect(effect: Effect) -> void:
	if effect is Effect:
		add_child(effect)
		_active_effects.append(effect)
		effect.terminated.connect(_cleanup_effect)

## remove any lingering aspects of an effect in this class
##
## called automatically on effect.terminate()
func _cleanup_effect(effect: Effect) -> void:
	if effect in _active_effects:
		_active_effects.erase(effect)
		if len(_active_effects) == 0:
			_terminate()

func _terminate() -> void:
	queue_free()
#endregion
