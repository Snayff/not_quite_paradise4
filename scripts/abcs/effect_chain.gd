## ABC for a series of effects
##
## an EffectChain usually remains active as a child of a [CombatActive], meaning it isnt freed and reinstatiated.
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
@export var _caster_required_tags: Array[Constants.COMBAT_TAG] = []  ## tags the caster must have to be able to activate
@export var target_required_tags: Array[Constants.COMBAT_TAG] = []  ## tags the target must have to be able to effect  # NOTE: not currently used. Should maybe be on the effect.
#endregion


#region VARS
var _caster: CombatActor
var _active_effects: Array[Effect] = []  ## an array of all active effects. Each effect needs to be removed when terminated.
#endregion


#region FUNCS
func set_caster(caster: CombatActor) -> void:
	_caster = caster

########### ACTIVATIONS ############
## check the conditions to activate are met
##
## this is usually casting, but can be activated by other means.
func can_activate() -> bool:
	var tags = _caster.get_node_or_null("Tags")
	if tags is TagsComponent:
		return tags.has_tags(_caster_required_tags)
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

func _terminate() -> void:
	queue_free()
#endregion
