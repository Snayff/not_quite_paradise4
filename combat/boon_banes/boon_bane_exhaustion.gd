## class desc
#@icon("")
class_name BoonBaneExhaustion
extends ABCBoonBane


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
func _configure_behaviour() -> void:
	# config behaviour
	# NOTE: until can come up with a good way to edit in the editor just hardcode it
	trigger = Constants.TRIGGER.on_application
	is_unique = true

	# create the effect
	var effect: AtomicActionApplyStatMod = AtomicActionApplyStatMod.new(self, _source)
	var statmod: StatModData             = StatModData.new()
	statmod.setup(0.5, Constants.MATH_MOD_TYPE.multiply)

	# apply to all stats
	var affected_stat_types: Array[Constants.STAT_TYPE] = [Constants.STAT_TYPE.strength, Constants.STAT_TYPE.defence]
	for stat_type in affected_stat_types:
		effect.add_mod(stat_type, statmod)

	_add_effect(effect)







#endregion