## interface for multiple [StatData]s.
@icon("res://assets/node_icons/stat_container.png")
class_name StatsContainerComponent
extends Node


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
@export_group("Details")
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
			push_warning("StatsContainerComponent: Multiple instances of ", stat.type, " found. Must be unique.")

## get a stat from the stat sheet.
##
## returns null if no matching stat found.
func get_stat(stat_type: Constants.STAT_TYPE) -> StatData:
	for stat_data in _stats:
		if stat_data.type == stat_type:
			return stat_data
	return null

func get_all_stats() -> Array[StatData]:
	return _stats

func add_mod(stat_type: Constants.STAT_TYPE, mod: StatModData) -> void:
	var stat = get_stat(stat_type)
	print(Utility.get_enum_name(Constants.STAT_TYPE, stat_type), " modified from ", stat.value)
	stat.add_mod(mod)
	print("-> to ", stat.value)

func remove_mod(stat_type: Constants.STAT_TYPE, mod: StatModData) -> void:
	var stat = get_stat(stat_type)
	stat.remove_mod(mod)

#endregion
