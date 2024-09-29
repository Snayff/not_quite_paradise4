extends BTAction

@export var range_min_in_direction: float = 40.0
@export var range_max_in_direction: float = 100.0

@export var position_var: StringName = &"pos"
@export var direction_var: StringName = &"direction"

func _tick(_delta: float) -> Status:
	var pos: Vector2
	var direction = random_direction()
	pos = random_position(direction)

	# update blackboard
	blackboard.set_var(position_var, pos)
	blackboard.set_var(direction_var, direction)

	print("direction: ", direction, " | pos: ", pos)

	return SUCCESS

# FIXME: only uses x
func random_position(direction: Vector2) -> Vector2:
	var distance = randi_range(range_min_in_direction, range_max_in_direction) * direction.x
	var final_position = (distance + agent.global_position.x)
	return Vector2(final_position, 0)

# FIXME: only uses x
func random_direction() -> Vector2:
	var direction_x = randi_range(-2, 1)  # 50/50 chance of postiive

	if abs(direction_x) != direction_x:
		direction_x = -1
	else:
		direction_x = 1

	var direction: Vector2 = Vector2(direction_x, 0)
	return direction
