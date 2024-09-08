## interface for all supplies, e.g. health or stamina.
@icon("res://assets/node_icons/supply_container.png")
class_name SupplyContainerComponent
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
func _ready() -> void:
	_duplicate_editor_resource_arrays()

	_check_all_unique()

	add_child(_regen_timer)
	_regen_timer.autostart = true
	_regen_timer.wait_time = 1
	_regen_timer.timeout.connect(_apply_regen_to_all_supplies)

## duplicate all supplies in _editor_supplies to _supplies
func _duplicate_editor_resource_arrays() -> void:
	for supply in _editor_supplies:
		_supplies.append(supply.duplicate(true))

func _check_all_unique() -> void:
	var types: Array[Constants.SUPPLY_TYPE] = []
	for supply in _supplies:
		if not supply.type in types:
			types.append(supply.type)
		else:
			push_error("SupplyContainerComponent: Contains duplicate supply type (", Constants.SUPPLY_TYPE.find_key(supply.type), ").")

## get a supply from its type. returns null if no matching supply found.
func get_supply(supply_type: Constants.SUPPLY_TYPE) -> SupplyComponent:
	for supply in _supplies:
		if supply.type == supply_type:
			return supply

	return null

func get_all_supplies() -> Array[SupplyComponent]:
	return _supplies

func _apply_regen_to_all_supplies() -> void:
	for supply in _supplies:
		supply.apply_regen()

#endregion
