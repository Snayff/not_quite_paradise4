## damage over time
class_name BoonBaneBurn
extends ABCBoonBane

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
	# NOTE: until can come up with a good way to edit in the editor just hardcode it

	# define base self
	f_name = "burn"
	type = Constants.BOON_BANE_TYPE.burn
	_max_stacks = 999
	_application_animation_scene = load("res://visual_effects/fire/fire.tscn")
	trigger = Constants.TRIGGER.on_interval
	_interval_length = 0.25
	_duration_type = Constants.DURATION_TYPE.time
	_duration = 2.5


	# define bespoke elements
	_damage_per_tick = 1
	var scaler = EffectStatScalerData.new()
	scaler.stat = Constants.STAT_TYPE.strength
	scaler.scale_value = 0.5
	_damage_scalers.append(scaler)


	# create damage
	var damage_effect: AtomicActionDealDamage = AtomicActionDealDamage.new(self, _source)
	@warning_ignore("narrowing_conversion")  # happy with reduced precision
	damage_effect.base_damage = _damage_per_tick
	damage_effect.is_one_shot = false
	damage_effect.scalers = _damage_scalers
	_add_effect(damage_effect)

	# create visual
	_create_application_animations()


#endregion
