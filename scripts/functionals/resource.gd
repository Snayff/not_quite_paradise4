## info regarding a changeable value, such as health or mana.
class_name ResourceComponent
extends Node

signal value_changed() ## the resource value has changed
signal emptied() ##  there is none of the resource left
signal max_value_changed() ## the resource's max value has changed

@export var value: int:
	set(value):
		value = value
		value_changed.emit()
		# Signal out when health is at 0
		if value == 0: emptied.emit()
@export var max_value: int:
	set(value):
		max_value = clamp(value, 1, INF)
		value_changed.emit()


## decrease the resource by an amount
func decrease(amount: int) -> void:
	value -= amount

## increase the resource by an amount
func increase(amount: int) -> void:
	clamp(value + amount, value, max_value)
