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


var _distance_min_squared: float
var _distance_max_squared: float


func _generate_name() -> String:
	return "IsTargetInRange: if %s is between %s and %s of agent" % [
		LimboUtility.decorate_var(target_actor_var),
		distance_min_var,
		distance_max_var
	]

func _enter() -> void:
	var distance_min: Variant = blackboard.get_var(distance_min_var)
	var distance_max: Variant = blackboard.get_var(distance_max_var)
	if distance_min is not float:
		distance_min = 0.0
	if distance_max is not float:
		distance_max = 0.0

	# square distance as faster to calc the comparison later
	_distance_min_squared = distance_min * distance_min
	_distance_max_squared = distance_max * distance_max

func _tick(_delta: float) -> Status:
	var target_actor: Actor = blackboard.get_var(target_actor_var, null)
	if not is_instance_valid(target_actor):
		return FAILURE

	if _distance_max_squared == 0.0:
		push_warning("max range of active is 0.0")
		return FAILURE

	var dist_sq: float = agent.global_position.distance_squared_to(target_actor.global_position)
	if dist_sq >= _distance_min_squared and dist_sq <= _distance_max_squared:
		return SUCCESS
	else:
		return FAILURE
