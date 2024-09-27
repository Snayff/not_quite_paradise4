## get a direction away from target
## [code]FAILURE[/code] if target is not valid.
@tool
extends BTAction

@export_group("Input")
@export var target_actor_var: StringName = &"target_actor"
@export_group("Output")
@export var target_direction_var: StringName = &"target_direction"

func _generate_name() -> String:
	return "GetFleeDirection: find direction away from %s ➜ %s as Vector2" % [
		LimboUtility.decorate_var(target_actor_var),
		LimboUtility.decorate_var(target_direction_var)
	]

func _tick(_delta: float) -> Status:
	var target_actor: Actor = blackboard.get_var(target_actor_var)
	if target_actor is not Actor:
		return FAILURE

	# FIXME: sometimes this isnt getting the direction away from the target, but is close
	var direction: Vector2 = agent.global_position.direction_to(target_actor.global_position)
	# invert to get move away direction
	var target_direction: Vector2 = -direction
	blackboard.set_var(target_direction_var, target_direction)

	return SUCCESS
