## the series of effects for the Circling Stars skill
class_name CirclingStarsEffectChain
extends EffectChain


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_category("Component Links")
# @export var
#
@export_category("On Hit")
@export var _damage: int = 1
#endregion


#region VARS

#endregion


#region FUNCS
func on_hit(hurtbox: HurtboxComponent) -> void:
	var actor_hit: CombatActor = hurtbox.root

	# initial damage
	var effect = DealDamageEffect.new(self)
	_register_effect(effect)
	effect.damage = _damage
	effect.apply(actor_hit)







#endregion
