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
	var aoe: ProjectileAreaOfEffect = Factory.create_projectile(
		"spike_explosion",
		_caster.allegiance.team,
		_caster.global_position
	)
	aoe.activate()






#endregion
