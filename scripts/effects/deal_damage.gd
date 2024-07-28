## class desc
#@icon("")
class_name DealDamageEffect
extends Effect


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_category("Component Links")
# @export var
@export_category("Details")
@export var damage: int = 1
#endregion


#region VARS

#endregion


#region FUNCS

## reduce health of target
func apply(target: CombatActor) -> void:
	var health = target.get_node_or_null("Health")
	if health is ResourceComponent:
		health.decrease(damage)







#endregion
