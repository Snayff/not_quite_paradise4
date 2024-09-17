## info regarding a changeable, numeric value, such as health or mana.
@icon("res://components/functionals/supply.png")
class_name Supply
extends Resource

#region SIGNALS
## the resource value has changed
signal value_changed()
## the resource value has decreased
signal value_decreased(amount: float)
## there is none of the resource left
signal emptied()
## the resource's max value has changed
signal max_value_changed()
#endregion


#region EXPORTS
@export_group("Details")
@export var type: Constants.SUPPLY_TYPE
@export var max_value: int = 999:
	set(value):
		max_value = clamp(value, 1, INF)
		if max_value < value:
			set_value(max_value)
			value_changed.emit()
		max_value_changed.emit()
## the amount the supply is increased by each time regeneration is applied.
@export var regeneration: float = 0
#endregion


#region VARS
## protective wrapper for the value. to set the value use [set_supply]
var value: int:
	set(value):
		push_warning("SupplyComponent: Can't set value directly. Use funcs.")
	get:
		return _value
var _value: int = 999:
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
## process setup
func setup(type_: Constants.SUPPLY_TYPE, max_value_: int, regeneration_: float) -> void:
	type = type_
	max_value = max_value_
	regeneration = regeneration_


#region FUNCS
## decrease the resource by an amount
func decrease(amount: int) -> void:
	_value -= amount
	value_decreased.emit(amount)

## increase the resource by an amount
func increase(amount: int) -> void:
	_value = clamp(value + amount, value, max_value)

## set the current and max value. If max_value not set, it is left as is.
func set_value(value_: int, max_value_: int = -1) -> void:
	_value = value_

	if max_value_ != -1:
		max_value = max_value_

## wrapper for increase using regeneration
func apply_regen() -> void:
	@warning_ignore("narrowing_conversion")  # happy with reduced precision
	increase(regeneration)
#endregion
