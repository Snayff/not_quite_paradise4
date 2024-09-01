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
# @export_group("Component Links")
# @export var
@export_group("Details")
@export var _caster_required_tags: Array[Constants.COMBAT_TAG] = []  ## tags the caster must have to be able to activate
@export var target_required_tags: Array[Constants.COMBAT_TAG] = []  ## tags the target must have to be able to effect  # NOTE: not currently used. Should maybe be on the effect.
#endregion


#region VARS
var _caster: CombatActor
var _active_effects: Array[Effect] = []  ## an array of all active effects. Each effect needs to be removed when terminated.
var _valid_effect_option: Constants.TARGET_OPTION  ## who the active's effects can affect. expedted from parent.
var _aoe_scene: PackedScene = preload("res://scenes/effect_delivery/aoe_explosion.tscn")  ## the scene for creating AOE
var _allegiance: Allegiance  ## the caster's allegiance. We take this rather than the team as the team can change, but this ref wont.
var _has_run_ready: bool = false  ## if _ready() has finished
#endregion


#region FUNCS
func _ready() -> void:
	_has_run_ready = true

## run setup process
func setup(caster: CombatActor, allegiance: Allegiance, valid_effect_option: Constants.TARGET_OPTION) -> void:
	if not _has_run_ready:
		push_error("EffectChain: setup() called before _ready. ")

	assert(caster is CombatActor, "EffectChain: `_caster` is missing. " )
	assert(allegiance is Allegiance, "EffectChain: `_allegiance` is missing. " )
	assert(valid_effect_option is Constants.TARGET_OPTION, "EffectChain: `_valid_effect_option` is missing. " )

	_caster = caster
	_valid_effect_option = valid_effect_option
	_allegiance = allegiance

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
## NOTE: not yet used
func activate() -> void:
	pass

## NOTE: not yet used
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
