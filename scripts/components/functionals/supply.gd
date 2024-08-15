## info regarding a changeable value, such as health or mana.
@icon("res://assets/node_icons/supply.png")
class_name SupplyComponent
extends Resource

#region SIGNALS
signal value_changed() ## the resource value has changed
signal value_decreased(amount: float) ## the resource value has decreased
signal emptied() ##  there is none of the resource left
signal max_value_changed() ## the resource's max value has changed
#endregion


#region EXPORTS
@export_group("Details")
@export var type: Constants.SUPPLY_TYPE  ## @REQUIRED.
@export var max_value: int = 999:  ## @REQUIRED.
	set(value):
		max_value = clamp(value, 1, INF)
		value_changed.emit()
@export var regeneration_per_second: float
#endregion


#region VARS
var value: int:
	set(value):
		push_warning("SupplyComponent: Can't set value directly. Use funcs.")
	get:
		return _value
var _value: int = 999:
	set(value):
		_value = value
		value_changed.emit()
		# Signal out when health is at 0
		if value <= 0: emptied.emit()

#endregion


#region FUNCS
func _init() -> void:
	resource_local_to_scene = true

## decrease the resource by an amount
func decrease(amount: int) -> void:
	_value -= amount
	value_decreased.emit(amount)

## increase the resource by an amount
func increase(amount: int) -> void:
	_value = clamp(value + amount, value, max_value)

func set_value(value_: int) -> void:
	_value = value_

## wrapper for increase using regeneration_per_second
func apply_regen() -> void:
	increase(regeneration_per_second)
#endregion
