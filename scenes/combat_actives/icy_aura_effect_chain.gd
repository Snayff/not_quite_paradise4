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

func _aoe_hit(hurtboxes: Array[HurtboxComponent]) -> void:
	var names = []
	for box in hurtboxes:
		names.append(box.root.name)
	print("aura hit: ", names)
	for hurtbox in hurtboxes:

		# apply boon_bane
		if not hurtbox.root.boons_banes is BoonsBanesContainerComponent:
			# no boon bane container to apply a boon bane to
			continue
		var chilled = Chilled.new(_caster)
		print("aura applied chilled")
		hurtbox.root.boons_banes.add_boon_bane(chilled)







#endregion
