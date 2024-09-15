## class desc
#@icon("")
class_name BoonBaneChilled
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
	f_name = "chilled"
	trigger = Constants.TRIGGER.on_application
	is_unique = true
	_duration = 10

	_duration_type = Constants.DURATION_TYPE.time
	_application_animation_scene = load("res://scenes/visual_effects/chilled.tscn")

	# create statmod effect
	var effect: AtomicActionApplyStatMod = AtomicActionApplyStatMod.new(self, _source)
	var statmod: StatModData             = StatModData.new()
	statmod.setup(0.7, Constants.MATH_MOD_TYPE.multiply)
	effect.add_mod(Constants.STAT_TYPE.move_speed, statmod)
	_add_effect(effect)

	# create visual
	var visual_effect: AtomicActionSpawnScene = AtomicActionSpawnScene.new(self, _source)
	visual_effect.scene = _application_animation_scene
	_add_effect(visual_effect)










#endregion
