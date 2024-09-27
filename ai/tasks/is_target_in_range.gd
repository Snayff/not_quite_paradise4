## checks if the agent is within a range of target,
## defined by [member distance_min] and [member distance_max].
## Returns [code]SUCCESS[/code] if the agent is within the defined range;
## otherwise, returns [code]FAILURE[/code].
@tool
extends BTCondition

@export_group("Input")
@export var distance_min_var: StringName = &""
@export var distance_max_var: StringName = &""
@export var target_actor_var: StringName = &"target_actor"
@export_group("Config")
## how far outside of min and max is acceptable
@export var tolerance: float = 0.0
## set a max distance
## if set, ignores distance_max_var
@export var distance_max_override: float = 0.0



var _distance_min_squared: float
var _distance_max_squared: float
var _tolerance_squared: float


func _generate_name() -> String:
	var min_ = "0"
	if distance_min_var != "":
		min_ = LimboUtility.decorate_var(distance_min_var)

	return "IsTargetInRange: if %s is between %s and %s of agent" % [
		LimboUtility.decorate_var(target_actor_var),
		min_,
		LimboUtility.decorate_var(distance_max_var)
	]

func _enter() -> void:
	print("Enter IsTargetInRange")
	var distance_min: Variant
	if blackboard.has_var(distance_min_var):
		blackboard.get_var(distance_min_var)

	var distance_max: Variant
	if blackboard.has_var(distance_max_var):
		blackboard.get_var(distance_max_var)

	if distance_min is not float:
		distance_min = 0.0
	if distance_max is not float:
		distance_max = 0.0

	if distance_max_override != 0.0:
		distance_max = distance_max_override

	# square distance as faster to calc the comparison later
	_distance_min_squared = distance_min * distance_min
	_distance_max_squared = distance_max * distance_max
	_tolerance_squared = tolerance * tolerance

func _tick(_delta: float) -> Status:
	print("Run IsTargetInRange")
	var target_actor: Actor = blackboard.get_var(target_actor_var, null)
	if not is_instance_valid(target_actor):
		return FAILURE

	# check if targeting self. if so, force success
	if target_actor == agent:
		print("IsTargetInRange - SUCCESS")
		return SUCCESS

	if _distance_max_squared == 0.0:
		print("Max range of active is 0.0")
		print("IsTargetInRange - FAILURE")
		return FAILURE

	var dist_sq: float = agent.global_position.distance_squared_to(target_actor.global_position)
	if (
		dist_sq >= _distance_min_squared - _tolerance_squared and \
		dist_sq <= _distance_max_squared + _tolerance_squared
	):
		print("IsTargetInRange - SUCCESS")
		return SUCCESS
	else:
		print("Noone in range")
		print("IsTargetInRange - FAILURE")
		return FAILURE
