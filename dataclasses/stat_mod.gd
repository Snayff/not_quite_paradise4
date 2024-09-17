## a modifier to a [Stat]
@icon("res://scripts/dataclasses/stat_mod.png")
class_name StatModData
extends Resource

#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
@export_group("Details")
@export var type: Constants.MATH_MOD_TYPE
@export var amount: float

#endregion


#region VARS

#endregion


#region FUNCS
func setup(amount_: float, type_: Constants.MATH_MOD_TYPE) -> void:
	type = type_
	amount = amount_



#endregion
