## apply one or more [StatModData]s to a target.
#@icon("")
class_name AtomicActionApplyStatMod
extends ABCAtomicAction


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
# @export_group("Details")
#endregion


#region VARS
var _stat_mods: Dictionary = {}  ## {Constsants.STAT_TYPE: [StatModData]}
#endregion


#region FUNCS
func apply(target: Actor) -> void:
	var stats: StatsContainer = target.get_node_or_null("StatsContainer")
	if stats is not StatsContainer:
		return

	# loop keys, which are the stat types
	for stat_type in _stat_mods.keys():
		if stat_type is not Constants.STAT_TYPE:
			push_error("ApplyStatModEffect: Key in `_stat_mods` is of wrong type.")

		# loop the array of statmoddata
		for mod in _stat_mods[stat_type]:
			if mod is not StatModData:
				push_error("ApplyStatModEffect: Value in `_stat_mods:", Utility.get_enum_name(Constants.STAT_TYPE, stat_type) ,"` is of wrong type.")
			stats.add_mod(stat_type, mod)

## add a [StatModData], for later application
func add_mod(stat_type: Constants.STAT_TYPE, mod: StatModData) -> void:
	if not _stat_mods.has(stat_type):
		_stat_mods[stat_type] = []

	_stat_mods[stat_type].append(mod)


func reverse_application(target: Actor) -> void:
	var stats: StatsContainer = target.get_node_or_null("StatsContainer")
	if stats is not StatsContainer:
		return

	# loop keys, which are the stat types
	for stat_type in _stat_mods.keys():
		if stat_type is not Constants.STAT_TYPE:
			push_error("ApplyStatModEffect: Key in `_stat_mods` is of wrong type.")

		# loop the array of statmoddata
		for mod in _stat_mods[stat_type]:
			if mod is not StatModData:
				push_error("ApplyStatModEffect: Value in `_stat_mods:", Utility.get_enum_name(Constants.STAT_TYPE, stat_type) ,"` is of wrong type.")
			stats.remove_mod(stat_type, mod)


#endregion
