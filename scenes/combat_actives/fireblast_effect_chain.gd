## the series of effects for the fireblast skill
class_name FireblastEffectChain
extends EffectChain


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
@export_group("Details")
@export var _aoe_damage: int = 1
@export var _damage_scalers: Array[EffectStatScalerData] = []

#endregion


#region VARS

#endregion


#region FUNCS
func on_hit(hurtbox: HurtboxComponent) -> void:
	# aoe
	var _aoe: AreaOfEffect = _aoe_scene.instantiate()
	# need to defer adding the _aoe as a child
	# as cannot add new Area2Ds to a scene during a call of another Area2D's on_area_entered()
	call_deferred("add_child", _aoe)
	await _aoe.ready
	_aoe.setup(hurtbox.global_position, _allegiance.team, _valid_effect_option)
	_aoe.hit_valid_targets.connect(_aoe_hit)

func _aoe_hit(hurtboxes: Array[HurtboxComponent]) -> void:
	# create damage effect
	var effect = DealDamageEffect.new(self, _caster)
	_register_effect(effect)
	effect.base_damage = _aoe_damage
	effect.scalers = _damage_scalers
	effect.is_one_shot = false

	for hurtbox in hurtboxes:

		# apply damage
		effect.apply(hurtbox.root)

		# apply boon_bane
		if not hurtbox.root.boons_banes is BoonsBanesContainerComponent:
			# no boon bane container to apply a boon bane to
			continue
		var burn = Burn.new(_caster)
		hurtbox.root.boons_banes.add_boon_bane(burn)

	# clean down damage effect
	effect.terminate()

#endregion
