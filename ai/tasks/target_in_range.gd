## checks if the agent is within a range of target,
## defined by [member distance_min] and [member distance_max].
## Returns [code]SUCCESS[/code] if the agent is within the defined range;
## otherwise, returns [code]FAILURE[/code].
@tool
extends BTCondition


## min distance of range
@export var distance_min: float
## max distance of range
@export var distance_max: float
## blackboard var for target
@export var target_actor_var: StringName = &"target_actor"


var _min_distance_squared: float
var _max_distance_squared: float


func _generate_name() -> String:
	return "TargetInRange: if %s is between %d and %d of agent" % [
		LimboUtility.decorate_var(target_actor_var),
		distance_min,
		distance_max
	]

func _setup() -> void:
	_min_distance_squared = distance_min * distance_min
	_max_distance_squared = distance_max * distance_max

func _tick(_delta: float) -> Status:
	var target_actor: Actor = blackboard.get_var(target_actor_var, null)
	if not is_instance_valid(target_actor):
		return FAILURE

	var dist_sq: float = agent.global_position.distance_squared_to(target_actor.global_position)
	if dist_sq >= _min_distance_squared and dist_sq <= _max_distance_squared:
		return SUCCESS
	else:
		return FAILURE
