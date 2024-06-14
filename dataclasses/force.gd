extends Resource
class_name ForceData

var name: String
var amount: float
var direction: Vector2
var duration: float
var max_duration: float
var reduces_over_time: bool

func _init(name_: String, amount_: float, direction_: Vector2, duration_: float, reduces_over_time_: bool) -> void:
	name = name_
	amount = amount_
	direction = direction_
	duration = duration_
	max_duration = duration_
	reduces_over_time = reduces_over_time_



