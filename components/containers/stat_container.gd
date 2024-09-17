## interface for initialising and managing [Stat]s.
@icon("res://components/containers/stat_container.png")
class_name StatsContainer
extends Node


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
@export_group("Details")
## this is a wrapper for _stats, due to godot's issue with arrays always sharing resources.
@export var _editor_stats: Array[Stat]
#endregion


#region VARS
## a unique list of all the stats copied from _editor_stats on _ready.
var _stats: Array[Stat]
#endregion


#region FUNCS
func _ready() -> void:
	_duplicate_editor_resource_arrays()
	_check_for_duplicates()

## duplicate all supplies in _editor_supplies to _supplies
##
## this is to account for the godot bug that has all editor resources ignore local_to_scene
func _duplicate_editor_resource_arrays() -> void:
	for stat in _editor_stats:
		_stats.append(stat.duplicate(true))

## check the _stats for multiple of the same stat and generate an error if there is a duplicate
func _check_for_duplicates() -> void:
	var check_array: Array = []
	for stat in _stats:
		if _stat_exists(stat.type):
			push_warning(
				"StatsContainer: Multiple instances of ",
				Utility.get_enum_name(Constants.STAT_TYPE, stat.type),
				" found. Must be unique."
			)

## check if a stat exists already
func _stat_exists(stat_type: Constants.STAT_TYPE) -> bool:
	var check_array: Array = []
	check_array = _stats.filter(func(x): return x.type == stat_type)
	if check_array.size() > 1:
		return true
	return false

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

		var value_ = stat_types[stat_type][0]
		var new_stat: Stat = Stat.new(stat_type, value_)
		_stats.append(new_stat)

## get a stat from the stat sheet.
##
## returns null if no matching stat found.
func get_stat(stat_type: Constants.STAT_TYPE) -> Stat:
	for stat_data in _stats:
		if stat_data.type == stat_type:
			return stat_data
	return null

func get_all_stats() -> Array[Stat]:
	return _stats

func add_mod(stat_type: Constants.STAT_TYPE, mod: StatModData) -> void:
	var stat: Stat = get_stat(stat_type)
	if stat == null:
		push_error("StatsContainer: stat_type (", Utility.get_enum_name(Constants.STAT_TYPE, stat_type), ") not recognised.")
	stat.add_mod(mod)

	# keep for debugging
	# print("mod added to ", Utility.get_enum_name(Constants.STAT_TYPE, stat_type), ". ID: ", stat)

func remove_mod(stat_type: Constants.STAT_TYPE, mod: StatModData) -> void:
	var stat: Stat = get_stat(stat_type)
	stat.remove_mod(mod)

#endregion
