## fireblast is a single target skill that triggers an aoe on hit.
class_name FireblastEffectChain
extends ABCEffectChain


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
@export_group("Details")
@export var _aoe_damage: int = 1
@export var _damage_scalers: Array[EffectStatScalerData] = []

#endregion


#region VARS

#endregion



#region FUNCS
func on_hit(hurtbox: HurtboxComponent) -> void:
	# FIXME: using hurtbox.global_position centres the explosion, whereas we want it at
	#		site of coliision
	Utility.call_next_frame(
		Factory.create_projectile,
		["explosion", _allegiance.team, hurtbox.global_position, _aoe_hit]
	)

func _aoe_hit(hurtboxes: Array[HurtboxComponent]) -> void:
	# create damage effect
	var effect = AtomicActionDealDamageEffect.new(self, _caster)
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
		var burn = BoonBaneBurn.new(_caster)
		hurtbox.root.boons_banes.add_boon_bane(burn)

	# clean down damage effect
	effect.terminate()

#endregion
