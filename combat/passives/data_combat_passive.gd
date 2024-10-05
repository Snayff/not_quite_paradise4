## data for creating a [ABCCombatPassive]
#@icon("res://projectiles/data_projectile.png")
class_name DataCombatPassive
extends Resource


#region EXPORTS
@export_group("Base")
@export var f_name: String = ""
@export var cooldown: float = 0.0

#endregion


#region VARS

#endregion


#region FUNCS
## define the dataclass
func define(
	f_name_: String,
	cooldown_: float,
	) -> DataCombatPassive:
	f_name = f_name_
	cooldown = cooldown_

	return self
