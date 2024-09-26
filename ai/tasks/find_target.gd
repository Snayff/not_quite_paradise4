## Stores the first [Actor] in the [member group] on the blackboard, returning [code]SUCCESS[/code].
## Returns [code]FAILURE[/code] if the group contains 0 [Actor]s.
@tool
extends BTAction

## name of group
## Constants.TEAM
@export var group: StringName
## blackboard var for target
@export var target_actor_var: StringName = &"target_actor"

func _generate_name() -> String:
	return "FindTarget: find target in \"%s\"  ➜%s" % [
		group,
		LimboUtility.decorate_var(target_actor_var)
	]

func _tick(delta: float) -> Status:
	var target_actor: Actor = get_target()

	if target_actor is Actor:
		blackboard.set_var(target_actor_var, target_actor)
		return SUCCESS
	else:
		return FAILURE

func get_target() -> Actor:
	var actors: Array[Node] = agent.get_tree().get_nodes_in_group(group)
	for actor in actors:
		if actor != agent:
			return actor

	return null
