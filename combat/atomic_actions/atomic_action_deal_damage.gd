## reduce a resource by a given amount, accounting for scaling and mitigants
#@icon("")
class_name AtomicActionDealDamageEffect
extends ABCAtomicAction

# NOTE: info on damage formulae:
# 	polynomial / exponential example:  ax^2 + bx + c, with a, b, and c being constants.
# 	e.g. (((strength) ^ 3 ÷ 32) + 32) x damage_multiplier
# 	damage multiplier would be set by the attack in question
#
# 	linear example: (a + b - c) * e
# 	e.g. (attacker_attack * damage_multiplier - defender_defence) * weakness_multiplier

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
var target_supply: Constants.SUPPLY_TYPE = Constants.SUPPLY_TYPE.health ## the supply_type to  reduce
var has_applied_damage: bool = false  ## if we have applied damage. used in conjunction with `is_one_shot` to prevent multiple applications due to fast movement
#endregion


#region FUNCS

## reduce health of target
func apply(target: Actor) -> void:
	if is_one_shot and has_applied_damage:
		return

	var supplies: SupplyContainer = target.get_node_or_null("SupplyContainer")
	if supplies is SupplyContainer:
		var supply = supplies.get_supply(target_supply)
		var damage = _calculate_damage(target)
		supply.decrease(damage)

		has_applied_damage = true

	if is_one_shot:
		terminate()

## wrapper for all damage calculations
func _calculate_damage(target: Actor) -> int:
	var damage = _apply_scalers()
	damage = _apply_resistances(target, damage)

	return damage

## base damage modified by scalers
func _apply_scalers() -> int:
	var damage = base_damage
	var stats: StatsContainer = _source.get_node_or_null("StatsContainer")
	if stats == null:
		return base_damage

	for scaler in scalers:
		damage += stats.get_stat(scaler.stat).value * scaler.scale_value

	return damage

## apply target's resistances to the given damage
##
## NOTE: will need to amend when we add more stats, to account for different resistances and damage types
func _apply_resistances(target: Actor, damage: int) -> int:
	var stats: StatsContainer = target.get_node_or_null("StatSheet")
	if stats == null:
		return damage

	@warning_ignore("narrowing_conversion")  # happy with reduced precision
	damage -= stats.get_stat(Constants.STAT_TYPE.defence).value
	return damage

#endregion
