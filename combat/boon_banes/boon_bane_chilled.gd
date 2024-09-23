## long, proportional slow
#@icon("")
class_name BoonBaneChilled
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
	f_name = "chilled"
	is_unique = true
	_application_animation_scene = load("res://visual_effects/chilled/chilled.tscn")
	trigger = Constants.TRIGGER.on_application
	_duration_type = Constants.DURATION_TYPE.time
	_duration = 10

	# create statmod effect
	var effect: AtomicActionApplyStatMod = AtomicActionApplyStatMod.new(self, _source)
	var statmod: StatModData = StatModData.new()
	statmod.setup(0.7, Constants.MATH_MOD_TYPE.multiply)
	effect.add_mod(Constants.STAT_TYPE.move_speed, statmod)
	_add_effect(effect)

	# create visual
	_create_application_visual_effects()










#endregion
