## class desc
#@icon("")
class_name IcyAuraEffectChain
extends EffectChain


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
# @export_group("Details")
#endregion


#region VARS

#endregion


#region FUNCS

func on_hit(hurtbox: HurtboxComponent) -> void:
	# apply boon_bane
	if not hurtbox.root.boons_banes is BoonsBanesContainerComponent:
		return
	var chilled = Chilled.new(_caster)
	hurtbox.root.boons_banes.add_boon_bane(chilled)







#endregion
