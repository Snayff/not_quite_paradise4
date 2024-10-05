## data for activating a [ABCCombatPassive]
#@icon("res://projectiles/data_projectile.png")
class_name DataCombatPassiveActivation
extends Resource


#region EXPORTS
@export_group("Base")
# FIXME: if we cant hold ref to an actor, maybe give actors a UID and keep a dict of all actors
# and their UID, then get actor back from that list
@export var target = -1
@export var trigger: Constants.TRIGGER

@export_group("Receive Damage")
@export var dmg_received: float = 0

#endregion


#region VARS

#endregion


#region FUNCS
## define the dataclass
func define(
	target_: Variant,
	trigger_: Constants.TRIGGER
	) -> DataCombatPassiveActivation:
	target = target_
	trigger = trigger_

	return self

## definition for Constants.TRIGGER.on_receive_damage. call after define.
func define_receive_damage(
	dmg_received_: float
	) -> DataCombatPassiveActivation:
	dmg_received = dmg_received_

	return self
