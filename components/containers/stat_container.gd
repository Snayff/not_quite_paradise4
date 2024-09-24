## interface for multiple [StatData]s.
@icon("res://components/containers/stat_container.png")
class_name StatsContainer
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
@export var _editor_stats: Array[StatData]  ## this is a wrapper for _stats, due to godot's issue with arrays always sharing resources.
#endregion


#region VARS
var _stats: Array[StatData]  ## a unique list of all the stats copied from _editor_stats on _ready.
#endregion


#region FUNCS

##########################
####### LIFECYCLE ######
######################

func _ready() -> void:
	_duplicate_editor_resource_arrays()
	_check_for_duplicates()

##########################
####### PUBLIC ##########
########################


## create a series of [Stat]s. Cannot create a duplicate of an existing stat type.
##
## stat_type_array: dictionary in the form of `STAT_TYPE : {value}`
func create_stats(stat_types: Dictionary) -> void:
	for stat_type in stat_types:

		# error if stat already exists
		if _stat_exists(stat_type):
			var printable_stat_type: String = Utility.get_enum_name(
				Constants.STAT_TYPE,
				stat_type
			)
			push_error(
				"StatsContainer: cant create stat (",
				printable_stat_type,
				") as already exists.")
			continue

		var value_ = stat_types[stat_type]
		var new_stat: StatData = StatData.new(stat_type, value_)
		_stats.append(new_stat)

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
	if stat == null:
		push_error("StatsContainer: stat_type (", Utility.get_enum_name(Constants.STAT_TYPE, stat_type), ") not recognised.")
	stat.add_mod(mod)

	# keep for debugging
	# print("mod added to ", Utility.get_enum_name(Constants.STAT_TYPE, stat_type), ". ID: ", stat)

func remove_mod(stat_type: Constants.STAT_TYPE, mod: StatModData) -> void:
	var stat = get_stat(stat_type)
	stat.remove_mod(mod)

##########################
####### PRIVATE #########
########################

## duplicate all supplies in _editor_supplies to _supplies
##
## this is to account for the godot bug that has all editor resources
func _duplicate_editor_resource_arrays() -> void:
	for stat in _editor_stats:
		_stats.append(stat.duplicate(true))

## check the _stats for multiple of the same stat and generate an error if there is a duplicate
func _check_for_duplicates() -> void:
	var check_array = []
	for stat in _stats:
		check_array.clear()
		check_array = _stats.filter(func(i): return i.type == stat.type)
		if check_array.size() > 1:
			push_warning("StatsContainer: Multiple instances of ", stat.type, " found. Must be unique.")

## check if a stat exists already
func _stat_exists(stat_type: Constants.STAT_TYPE) -> bool:
	var check_array: Array = []
	check_array = _stats.filter(func(x): return x.type == stat_type)
	if check_array.size() > 0:
		return true
	return false

#endregion
