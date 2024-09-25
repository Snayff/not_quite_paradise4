## reduce a resource by a given amount, accounting for scaling and mitigants
#@icon("")
class_name AtomicActionDealDamage
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
## if true, terminates after 1 application. if false, needs to be terminated manually.
var is_one_shot: bool = true
var base_damage: int = 0
var scalers: Array[EffectStatScalerData] = []
## the supply_type to  reduce
var target_supply: Constants.SUPPLY_TYPE = Constants.SUPPLY_TYPE.health
## if we have applied damage.
## used in conjunction with `is_one_shot` to prevent multiple applications due to fast movement
var has_applied_damage: bool = false
## the multiplier to apply to the damage.
## often used by [ABCBoonBane] for stacks.
var multiplier: int = 1


#endregion


#region FUNCS

## reduce health of target. uses `multiplier` then resets it to 0.
func apply(target: Actor) -> void:
	if is_one_shot and has_applied_damage:
		return

	var supplies: SupplyContainer = target.get_node_or_null("SupplyContainer")
	if supplies is SupplyContainer:
		var supply: SupplyComponent = supplies.get_supply(target_supply)
		var damage: int = _calculate_damage(target)
		var mult_damage = damage * multiplier
		supply.decrease(mult_damage)

		has_applied_damage = true

	if is_one_shot:
		terminate()

	# reset multiplier
	multiplier = 1

## wrapper for all damage calculations
func _calculate_damage(target: Actor) -> int:
	var damage: int = _apply_scalers()
	damage = _apply_resistances(target, damage)

	return damage

## base damage modified by scalers
func _apply_scalers() -> int:
	var damage: int = base_damage
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
