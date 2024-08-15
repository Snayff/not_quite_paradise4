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
@export_group("On Hit")
@export var _damage: int = 1

#endregion


#region VARS

#endregion


#region FUNCS
func on_hit(hurtbox: HurtboxComponent) -> void:
	var actor_hit: CombatActor = hurtbox.root

	# initial damage
	var effect = DealDamageEffect.new(self, _caster)
	_register_effect(effect)
	effect.base_damage = _damage
	effect.apply(actor_hit)

	# apply boon_bane
	if not actor_hit.boons_banes is BoonsBanesContainerComponent:
		# no boon bane container to apply a boon bane to
		return
	var burn = Burn.new(_caster)
	actor_hit.boons_banes.add_boon_bane(burn)

#endregion
