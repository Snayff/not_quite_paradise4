## the series of effects for the Circling Stars skill
@icon("res://combat/actives/effect_chain.png")
class_name EffectChainCirclingStars
extends ABCEffectChain


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
@export_group("On Hit")
@export var _damage: int = 1
@export var _damage_scalers: Array[EffectStatScalerData] = []
#endregion


#region VARS

#endregion


#region FUNCS
func on_hit(hurtbox: HurtboxComponent) -> void:
	var actor_hit: CombatActor = hurtbox.root

	# initial damage
	var effect = AtomicActionDealDamage.new(self, _caster)
	_register_effect(effect)
	effect.base_damage = _damage
	effect.scalers = _damage_scalers
	effect.apply(actor_hit)







#endregion
