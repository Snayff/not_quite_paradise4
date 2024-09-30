## info regarding a changeable value, such as health or mana.
@icon("res://components/functionals/supply.png")
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
@export var type: Constants.SUPPLY_TYPE
@export var max_value: float = 999:
	set(value):
		max_value = clamp(value, 1, INF)
		if max_value < value:
			set_value(max_value)
			value_changed.emit()
		max_value_changed.emit()
@export var regeneration: float = 0
#endregion


#region VARS
## the current value of the supply
##
## protected value. to set the value use [set_value]
var value: float:
	set(value):
		push_warning("SupplyComponent: Can't set value directly. Use funcs.")
	get:
		return _value
var _value: float = 999:
	set(value):
		if value > max_value:
			_value = max_value
		else:
			_value = value
		value_changed.emit()
		# Signal out when health is at 0
		if value <= 0:
			emptied.emit()

#endregion


#region FUNCS
## process setup
func setup(type_: Constants.SUPPLY_TYPE, max_value_: int, regeneration_: float) -> void:
	type = type_
	max_value = max_value_
	regeneration = regeneration_

## decrease the resource by an amount
func decrease(amount: float) -> void:
	_value -= amount
	value_decreased.emit(amount)

## increase the resource by an amount
func increase(amount: float) -> void:
	_value = clamp(value + amount, value, max_value)

## set the current and max value. If max_value not set, it is left as is.
func set_value(value_: float, max_value_: float = -1) -> void:
	_value = value_

	if max_value_ != -1:
		max_value = max_value_

## wrapper for increase using regeneration
func apply_regen() -> void:
	@warning_ignore("narrowing_conversion")  # happy with reduced precision
	increase(regeneration)
#endregion
