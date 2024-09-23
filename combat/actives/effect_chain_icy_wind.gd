## series of effects for Icy Aura. applies [BoonBaneChilled] to hit actors.
@icon("res://combat/actives/effect_chain.png")
class_name EffectChainIcyWind
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
	#var chilled = BoonBaneChilled.new(_caster)
	#hurtbox.root.boons_banes.add_boon_bane(chilled)
	var container: BoonBaneContainer = hurtbox.root.boons_banes
	var num_stacks: int = 2
	#var chilled = Factory.create_boon_bane(Constants.BOON_BANE_TYPE.chilled, container, _caster)
	container.add_boon_bane(Constants.BOON_BANE_TYPE.chilled, _caster, num_stacks)







#endregion
