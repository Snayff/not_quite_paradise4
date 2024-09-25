## interface for all supplies, e.g. health or stamina.
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
#NOTE: should probs be a dict[SUPPLY_TYPE: SupplyComponent], but need typed dicts to make using editor feasible
@export var _editor_supplies: Array[SupplyComponent] = []  ## this is a wrapper for _supplies, due to godot's issue with arrays always sharing resources.
#endregion


#region VARS
var _regen_timer: Timer = Timer.new()
var _supplies: Array[SupplyComponent]  ## all supplies. copied from _editor_supplies on _ready.
#endregion


#region FUNCS

##########################
####### LIFECYCLE ######
######################

func _ready() -> void:
	_duplicate_editor_resource_arrays()

	_check_all_unique()

	# config regen
	add_child(_regen_timer)
	_regen_timer.autostart = true
	_regen_timer.wait_time = 1
	_regen_timer.timeout.connect(_apply_regen_to_all_supplies)

##########################
####### PUBLIC ##########
########################

## create a series of [Supply]s. Cannot create a duplicate of an existing supply type.
##
## supply_types: dictionary in the form of `SUPPLY_TYPE : [{max_value}, {regen_value}]`
func create_supplies(supply_types: Dictionary) -> void:
	for supply_type in supply_types.keys():

		# error if stat already exists
		if _supply_exists(supply_type):
			var printable_supply_type: String = Utility.get_enum_name(
				Constants.SUPPLY_TYPE,
				supply_type
			)
			push_error(
				"SupplyContainer: cant create supply (",
				printable_supply_type,
				") as already exists.")
			continue

		var max_value_ = supply_types[supply_type][0]
		var regen_value_ = supply_types[supply_type][1]
		var new_supply: SupplyComponent = SupplyComponent.new()
		new_supply.resource_local_to_scene = true
		new_supply.resource_name = Utility.get_enum_name(Constants.SUPPLY_TYPE, supply_type)
		new_supply.setup(supply_type, max_value_, regen_value_)
		_supplies.append(new_supply)

## get a supply from its type. returns null if no matching supply found.
func get_supply(supply_type: Constants.SUPPLY_TYPE) -> SupplyComponent:
	for supply in _supplies:
		if supply.type == supply_type:
			return supply

	return null

func get_all_supplies() -> Array[SupplyComponent]:
	return _supplies


##########################
####### PRIVATE #########
########################

## duplicate all supplies in _editor_supplies to _supplies
##
## this is to account for the godot bug that has all editor resources
func _duplicate_editor_resource_arrays() -> void:
	for supply in _editor_supplies:
		_supplies.append(supply.duplicate(true))

func _check_all_unique() -> void:
	var types: Array[Constants.SUPPLY_TYPE] = []
	for supply in _supplies:
		if not supply.type in types:
			types.append(supply.type)
		else:
			push_error("SupplyContainer: Contains duplicate supply type (", Constants.SUPPLY_TYPE.find_key(supply.type), ").")

func _apply_regen_to_all_supplies() -> void:
	for supply in _supplies:
		supply.apply_regen()

## check if a supply exists already
func _supply_exists(supply_type: Constants.SUPPLY_TYPE) -> bool:
	var check_array: Array = []
	check_array = _supplies.filter(func(x): return x.type == supply_type)
	if check_array.size() > 0:
		return true
	return false

#endregion
