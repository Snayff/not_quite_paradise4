## a numerical statistic, with helper functionality for handling modification
##
## for modifiers, additions are handled before multiplications
@icon("res://assets/node_icons/stat.png")
class_name StatData
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
@export var type: Constants.STAT
@export var base_value: float
#endregion


#region VARS
var _modifiers: Array[StatModData]
var _modified_value: float  ## base_value modified by all _modifiers
var value: float:
	set(value_):
		push_error("StatData: Can't set directly.")
	get:
		_recalculate()
		return _modified_value
#endregion


#region FUNCS
func _init(type_: Constants.STAT, base_value_: float) -> void:
	resource_local_to_scene = true
	type = type_
	base_value = base_value_

## recalculate the current value
func _recalculate() -> void:
	_modified_value = base_value
	var multiplier: float = 1
	for mod in _modifiers:
		if mod.type == Constants.STAT_MOD.add:
			_modified_value += mod.amount

		elif  mod.type == Constants.STAT_MOD.multiply:
			multiplier += mod.amount

		else:
			push_warning("StatData: unable to handle mod type of ", mod.type, ".")

	_modified_value *= multiplier

#endregion
