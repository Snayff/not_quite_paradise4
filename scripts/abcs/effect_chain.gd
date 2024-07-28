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
#endregion


#region FUNCS

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

#endregion
