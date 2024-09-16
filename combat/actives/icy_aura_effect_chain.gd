## series of effects for Icy Aura. applies [BoonBaneChilled] to hit actors.
#@icon("")
class_name IcyAuraEffectChain
extends ABCEffectChain


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
	if not hurtbox.root.boons_banes is BoonBaneContainer:
		return
	var chilled = BoonBaneChilled.new(_caster)
	hurtbox.root.boons_banes.add_boon_bane(chilled)







#endregion
