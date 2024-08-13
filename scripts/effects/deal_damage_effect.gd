## reduce a resource by a given amount, accounting for scaling and mitigants
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
#@export_category("Details")

#endregion


#region VARS
var is_one_shot: bool = true  ## if true, terminates after 1 application. if false, needs to be terminated manually.
var base_damage: int
var scalers: Array[EffectStatScalerData] = []
#endregion


#region FUNCS

## reduce health of target
func apply(target: CombatActor) -> void:
	# TODO: enable targeting any resource
	var health = target.get_node_or_null("Health")
	if health is ResourceComponent:
		var damage = _calculate_damage(target)
		health.decrease(damage)

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
	var stats: StatSheetComponent = _source.get_node_or_null("StatSheet")
	if stats == null:
		return base_damage

	for scaler in scalers:
		damage += stats.get_stat(scaler.stat).value * scaler.scale_value

	return damage

## apply target's resistances to the given damage
##
## NOTE: will need to amend when we add more stats, to account for different resistances and damage types
func _apply_resistances(target: CombatActor, damage: int) -> int:
	var stats: StatSheetComponent = target.get_node_or_null("StatSheet")
	if stats == null:
		return damage

	damage -= stats.get_stat(Constants.STAT.defence).value
	return damage

#endregion
