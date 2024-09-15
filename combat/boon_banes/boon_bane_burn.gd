## damage over time
#@icon("")
class_name BoonBaneBurn
extends ABCBoonBane


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
@export_group("Effects")
@export_subgroup("Damage Effect")
@export var _damage_per_tick: float = 0
@export var _damage_scalers: Array[EffectStatScalerData] = []
#endregion


#region VARS

#endregion


#region FUNCS
func _configure_behaviour() -> void:
	# config behaviour
	# NOTE: until can come up with a good way to edit in the editor just hardcode it
	f_name = "burn"
	_damage_per_tick = 1
	var scaler = EffectStatScalerData.new()
	scaler.stat = Constants.STAT_TYPE.strength
	scaler.scale_value = 0.5
	_damage_scalers.append(scaler)
	_application_animation_scene = load("res://scenes/visual_effects/fire.tscn")
	_duration = 2.5
	_duration_type = Constants.DURATION_TYPE.time
	trigger = Constants.TRIGGER.on_interval
	_interval_length = 0.25
	is_unique = false

	# create damage
	var damage_effect: AtomicActionDealDamageEffect = AtomicActionDealDamageEffect.new(self, _source)
	@warning_ignore("narrowing_conversion")  # happy with reduced precision
	damage_effect.base_damage = _damage_per_tick
	damage_effect.is_one_shot = false
	damage_effect.scalers = _damage_scalers
	_add_effect(damage_effect)

	# create visual
	var visual_effect: AtomicActionSpawnScene = AtomicActionSpawnScene.new(self, _source)
	visual_effect.scene = _application_animation_scene
	_add_effect(visual_effect)

#endregion
