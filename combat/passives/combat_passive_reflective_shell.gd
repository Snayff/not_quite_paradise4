## class desc
#@icon("")
class_name CombatPassiveReflectiveShell
extends ABCCombatPassive


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
# @export_group("Details")
#endregion


#region VARS

#endregion


#region FUNCS
func setup(combat_passive_name_: String, caster: Actor) -> void:
	super.setup(combat_passive_name_, caster)

	_triggers_used.append(Constants.TRIGGER.on_receive_damage)

@warning_ignore("unused_parameter")  # required by virtual method
func _on_receive_damage(data: DataCombatPassive) -> void:
	return

	# TODO: need to set the cooldown of passive as either global or per target
	# 		so that we can control whether soemthing like this can trigger multiple times
	#		in a row, regardless of whether from multiple people
	# TODO: prevent being caused by self damage
	var aoe: ProjectileAreaOfEffect = Factory.create_projectile(
		"spike_explosion",
		_caster.allegiance.team,
		_caster.global_position,
		_aoe_hit
	)

func _aoe_hit(hurtboxes: Array[HurtboxComponent]) -> void:
	# TODO: should this be an EffectChain? We're doing almost the same, other than
	# 	the trigger we use

	# create damage effect
	var effect = AtomicActionDealDamage.new(self, _caster)
	#_register_effect(effect)
	effect.base_damage = 999
	#effect.scalers = _damage_scalers
	effect.is_one_shot = false

	for hurtbox in hurtboxes:

		# apply damage
		effect.apply(hurtbox.root)

	# clean down damage effect
	effect.terminate()






#endregion
