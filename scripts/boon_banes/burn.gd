## damage over time
#@icon("")
class_name Burn
extends BoonBane


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
@export_subgroup("Visual Effect")
@export var _application_animation_scene: PackedScene
#endregion


#region VARS

#endregion


#region FUNCS
func _configure_behaviour() -> void:
	# config behaviour
	# NOTE: until can come up with a good way to edit in the editor just hardcode it
	_damage_per_tick = 1
	var scaler = EffectStatScalerData.new()
	scaler.stat = Constants.STAT_TYPE.strength
	scaler.scale_value = 0.5
	_damage_scalers.append(scaler)
	_application_animation_scene = load("res://scenes/visual_effects/fire.tscn")
	_duration = 2.5
	trigger = Constants.TRIGGER.on_interval
	_duration_type = Constants.DURATION_TYPE.time
	_interval_length = 0.25
	is_unique = false

	# create effects
	var damage_effect: DealDamageEffect = DealDamageEffect.new(self, _source)
	damage_effect.base_damage = _damage_per_tick
	damage_effect.is_one_shot = false
	damage_effect.scalers = _damage_scalers
	_add_effect(damage_effect)
	var visual_effect: SpawnSceneEffect = SpawnSceneEffect.new(self, _source)
	visual_effect.scene = _application_animation_scene
	_add_effect(visual_effect)

#endregion
