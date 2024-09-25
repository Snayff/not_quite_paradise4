extends BTAction

@export var target_pos_var: StringName = &"pos"
@export var direction_var: StringName = &"direction"

@export var speed_var: float = 40.0
@export var tolerance: float = 10.0

func _tick(_delta: float) -> Status:
	# get info from blackboard
	var target_pos: Vector2 = blackboard.get_var(target_pos_var, Vector2.ZERO)
	var direction: Vector2 = blackboard.get_var(direction_var)

	# check within tolerance of destination
	if abs(agent.global_position.x - target_pos.x) < tolerance:
		agent.move(direction)
		return SUCCESS

	# keep moving
	else:
		agent.move(direction, speed_var)
		return RUNNING
