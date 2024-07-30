## the series of effects for the fireblast skill, when it hits
class_name FireblastEffectChain
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
@export_category("Interval")
@export var _repeat_damage: int = 1
@export var _num_iterations: int = 10
@export var _interval: float = 1
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

	# repeating damage
	effect = RepeatApplicationEffect.new(self)
	_register_effect(effect)
	effect.interval = _interval
	effect.num_iterations = _num_iterations
	var interval_effect = DealDamageEffect.new(self)
	interval_effect.damage = _repeat_damage
	interval_effect.is_one_shot = false
	effect.add_repeating_effect(interval_effect)
	effect.apply(actor_hit)

	# TODO: add create visual effect




#endregion
