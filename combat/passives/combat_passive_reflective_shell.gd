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

func _on_receive_damage(data: DataCombatPassive) -> void:
	var aoe: ProjectileAreaOfEffect = Factory.create_projectile(
		"spike_explosion",
		data.target.allegiance.team,
		data.target.global_position
	)
	aoe.activate()






#endregion
