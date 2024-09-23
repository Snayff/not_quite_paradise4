## series of effects for Slash. deals damage to all actors hit
@icon("res://combat/actives/effect_chain.png")
class_name EffectChainSlash
extends ABCEffectChain


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
@export_group("Details")
@export var _damage: int = 0
@export var _damage_scalers: Array[EffectStatScalerData] = []
#endregion


#region VARS

#endregion


#region FUNCS
func on_hit(hurtbox: HurtboxComponent) -> void:
	var actor_hit: CombatActor = hurtbox.root

	var effect = AtomicActionDealDamage.new(self, _caster)
	_register_effect(effect)
	effect.base_damage = _damage
	effect.scalers = _damage_scalers
	effect.apply(actor_hit)







#endregion
