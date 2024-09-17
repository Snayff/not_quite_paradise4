## interface for all supplies, e.g. health,  stamina, etc.. All regen is applied at same tick.
@icon("res://components/containers/supply_container.png")
class_name SupplyContainer
extends Node


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
#@export_group("Component Links")
@export_group("Details")
#NOTE: should probs be a dict[SUPPLY_TYPE: Supply], but need typed dicts to make using editor feasible
## this is a wrapper for _supplies, due to godot's issue with arrays always sharing resources.
@export var _editor_supplies: Array[Supply] = []
#endregion


#region VARS
## timer to manage triggering of regen for all [Supply] children.
var _regen_timer: Timer = Timer.new()
## all supplies. copied from _editor_supplies on _ready.
var _supplies: Array[Supply]
#endregion


#region FUNCS
func _ready() -> void:
	_duplicate_editor_resource_arrays()

	_check_all_unique()

	# setup timer
	add_child(_regen_timer)
	_regen_timer.autostart = true
	_regen_timer.wait_time = Constants.REGEN_TICK_RATE
	_regen_timer.timeout.connect(_apply_regen_to_all_supplies)

## duplicate all supplies in _editor_supplies to _supplies
##
## this is to account for the godot bug that has all editor resources ignore local_to_scene
func _duplicate_editor_resource_arrays() -> void:
	for supply in _editor_supplies:
		_supplies.append(supply.duplicate(true))

func _check_all_unique() -> void:
	var types: Array[Constants.SUPPLY_TYPE] = []
	for supply in _supplies:
		if not supply.type in types:
			types.append(supply.type)
		else:
			push_error(
				"SupplyContainer: Contains duplicate supply type (",
				Constants.SUPPLY_TYPE.find_key(supply.type),
				")."
			)

## create a series of [Supply]s. Cannot create a duplicate of an existing supply type.
##
## supply_type_array: array of dictionaries in the form of
## `SUPPLY_TYPE : [{max_value}, {regen_value}]`
func create_supplies(supply_type_array: Array[Dictionary]) -> void:
	for i in supply_type_array:
		var supply_type = supply_type_array[i].keys()[0]

		# error if stat already exists
		if _supply_exists(supply_type):
			var printable_stat_type: String = Utility.get_enum_name(
				Constants.STAT_TYPE,
				supply_type
			)
			push_error(
				"StatsContainer: cant create stat (",
				printable_stat_type,
				") as already exists.")
			continue


		var max_value_ = supply_type_array[i].values()[0]
		var regen_value_ = supply_type_array[i].values()[1]
		var new_supply: Supply = Supply.new()
		new_supply.setup(supply_type, max_value_, regen_value_)
		_supplies.append(new_supply)


## get a supply from its type. returns null if no matching supply found.
func get_supply(supply_type: Constants.SUPPLY_TYPE) -> Supply:
	for supply in _supplies:
		if supply.type == supply_type:
			return supply

	return null

func get_all_supplies() -> Array[Supply]:
	return _supplies

func _apply_regen_to_all_supplies() -> void:
	for supply in _supplies:
		supply.apply_regen()


## check if a supply exists already
func _supply_exists(supply_type: Constants.SUPPLY_TYPE) -> bool:
	var check_array: Array = []
	check_array = _supplies.filter(func(x): return x.type == supply_type)
	if check_array.size() > 1:
		return true
	return false
#endregion
