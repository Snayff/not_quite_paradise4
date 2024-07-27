## abc for a series of effects
#@icon("")
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
@export var target_required_tags: Array[Constants.COMBAT_TAG] = []  ## tags the target must have to be able to activate
#endregion


#region VARS

#endregion


#region FUNCS
## check the conditions to activate are met
func can_activate() -> bool:
	return false

## activate the chain of effects
func activate() -> void:
	pass




#endregion
