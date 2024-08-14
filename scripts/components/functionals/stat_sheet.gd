## interface for multiple [StatData]s.
@icon("res://assets/node_icons/stat_sheet.png")
class_name StatSheetComponent
extends Node


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_category("Component Links")
# @export var
#
@export_category("Details")
@export var _stats: Array[StatData]  ## a unique list of all the stats
#endregion


#region VARS

#endregion


#region FUNCS

func _ready() -> void:
	_check_for_duplicates()

## check the _stats for multiple of the same stat and generate an error if there is a duplicate
##
## TODO: this should be an editor warning, too
func _check_for_duplicates() -> void:
	var check_array = []
	for stat in _stats:
		check_array.clear()
		check_array = _stats.filter(func(i): return i.type == stat.type)
		if check_array.size() > 1:
			push_warning("StatSheetComponent: Multiple instances of ", stat.type, " found. Must be unique.")

## get a stat from the stat sheet. nullable.
func get_stat(stat: Constants.STAT_TYPE) -> StatData:
	for stat_data in _stats:
		if stat_data.type == stat:
			return stat_data
	return null

#endregion
