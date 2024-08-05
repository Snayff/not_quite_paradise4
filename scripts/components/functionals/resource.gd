## info regarding a changeable value, such as health or mana.
@icon("res://assets/node_icons/resource.png")
class_name ResourceComponent
extends Node


signal value_changed() ## the resource value has changed
signal value_decreased(amount: float) ## the resource value has decreased
signal emptied() ##  there is none of the resource left
signal max_value_changed() ## the resource's max value has changed


@export_category("Details")
@export var _value: int = 999:
	set(value):
		_value = value
		value_changed.emit()
		# Signal out when health is at 0
		if value <= 0: emptied.emit()
@export var max_value: int = 999:
	set(value):
		max_value = clamp(value, 1, INF)
		value_changed.emit()
@export var regeneration_per_second: float


var value: int:
	set(value):
		push_warning("ResourceComponent: Can't set value directly. Use funcs.")
	get:
		return _value
var _regen_timer: Timer = Timer.new()


func _ready() -> void:
	# setup regen timer
	add_child(_regen_timer)
	_regen_timer.autostart = true
	_regen_timer.wait_time = 1
	_regen_timer.timeout.connect(increase.bind(regeneration_per_second))

## decrease the resource by an amount
func decrease(amount: int) -> void:
	_value -= amount
	value_decreased.emit(amount)

## increase the resource by an amount
func increase(amount: int) -> void:
	_value = clamp(value + amount, value, max_value)

func set_value(value_: int) -> void:
	_value = value_
