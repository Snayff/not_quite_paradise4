## reduce a resource by a given amount, accounting for scaling and mitigants
#@icon("")
class_name DealDamageEffect
extends Effect


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#@export_group("Details")

#endregion


#region VARS
var is_one_shot: bool = true  ## if true, terminates after 1 application. if false, needs to be terminated manually.
var base_damage: int
var scalers: Array[EffectStatScalerData] = []
var target_resource: String = "Health"  ## name of resource component. must match resource nodes name.
#endregion


#region FUNCS

## reduce health of target
func apply(target: CombatActor) -> void:
	var resource = target.get_node_or_null(target_resource)
	if resource is SupplyComponent:
		var damage = _calculate_damage(target)
		resource.decrease(damage)

	if is_one_shot:
		terminate()

## wrapper for all damage calculations
func _calculate_damage(target: CombatActor) -> int:
	var damage = _apply_scalers()
	damage = _apply_resistances(target, damage)

	return damage

## base damage modified by scalers
func _apply_scalers() -> int:
	var damage = base_damage
	var stats: StatsContainerComponent = _source.get_node_or_null("StatSheet")
	if stats == null:
		return base_damage

	for scaler in scalers:
		damage += stats.get_stat(scaler.stat).value * scaler.scale_value

	return damage

## apply target's resistances to the given damage
##
## NOTE: will need to amend when we add more stats, to account for different resistances and damage types
func _apply_resistances(target: CombatActor, damage: int) -> int:
	var stats: StatsContainerComponent = target.get_node_or_null("StatSheet")
	if stats == null:
		return damage

	damage -= stats.get_stat(Constants.STAT_TYPE.defence).value
	return damage

#endregion
