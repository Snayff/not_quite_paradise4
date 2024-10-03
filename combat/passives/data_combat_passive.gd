## data for [ABCCombatPassive]
#@icon("res://projectiles/data_projectile.png")
class_name DataCombatPassive
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
	) -> void:
	target = target_
	trigger = trigger_

## definition for Constants.TRIGGER.on_receive_damage. call after define.
func define_receive_damage(
	dmg_received_: float
	) -> void:
	dmg_received = dmg_received_