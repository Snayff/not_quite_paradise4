## permanent reduction in all stats
class_name BoonBaneExhaustion
extends ABCBoonBane

#region EXPORTS
# @export_group("Details")
#endregion


#region VARS

#endregion


#region FUNCS
func _configure_behaviour() -> void:
	# NOTE: until can come up with a good way to edit in the editor just hardcode it

	# define base self
	f_name = "exhaustion"
	type = Constants.BOON_BANE_TYPE.exhaustion
	is_unique = true
	var animation: PackedScene = load("res://visual_effects/exhaustion/exhaustion.tscn")
	_application_animation_scene = animation
	trigger = Constants.TRIGGER.on_application
	_duration_type = Constants.DURATION_TYPE.permanent
	_reminder_animation_scene = animation
	_reminder_animation_interval = 2.0

	# create the effect
	var effect: AtomicActionApplyStatMod = AtomicActionApplyStatMod.new(self, _source)
	var statmod: StatModData = StatModData.new()
	statmod.setup(0.5, Constants.MATH_MOD_TYPE.multiply)

	# apply to all stats
	var affected_stat_types: Array[Constants.STAT_TYPE] = [Constants.STAT_TYPE.strength, Constants.STAT_TYPE.defence]
	for stat_type in affected_stat_types:
		effect.add_mod(stat_type, statmod)

	_add_effect(effect)

	# create visuals
	_create_application_animations()







#endregion
