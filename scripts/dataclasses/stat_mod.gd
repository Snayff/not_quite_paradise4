## a modifier to a [StatData]
@icon("res://assets/node_icons/stat_mod.png")
class_name StatModData
extends Resource

#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_category("Component Links")
# @export var
#
@export_category("Details")
@export var type: Constants.STAT_MOD
@export var amount: float
# TODO: duration and duration type, e.g. num applications or time
#endregion


#region VARS

#endregion


#region FUNCS
func _init(type_: Constants.STAT_MOD = Constants.STAT_MOD.add, amount_: float = 0) -> void:
	resource_local_to_scene = true
	type = type_
	amount = amount_









#endregion
