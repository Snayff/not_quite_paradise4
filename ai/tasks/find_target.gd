## Stores the first [Actor] in the team_var. Found via group.
## Returns [code]FAILURE[/code] if the group contains 0 [Actor]s.
@tool
extends BTAction

@export_group("Input")
@export var team_var: StringName = &"team"
@export_group("Output")
@export var target_actor_var: StringName = &"target_actor"
@export_group("Config")
@export var enemy_or_ally: Constants.TARGET_OPTION = Constants.TARGET_OPTION.enemy

func _generate_name() -> String:
	return "FindTarget: find target in %s ➜ %s as Actor" % [
		LimboUtility.decorate_var(team_var),
		LimboUtility.decorate_var(target_actor_var)
	]

func _tick(delta: float) -> Status:
	var target_actor: Actor = get_target()

	if target_actor is Actor:
		blackboard.set_var(target_actor_var, target_actor)
		return SUCCESS
	else:
		print("find target failed")
		return FAILURE

func get_target() -> Actor:
	var team: Constants.TEAM = blackboard.get_var(team_var)
	if team == null:
		return null

	var group = get_group(team)
	if group == "":
		return null

	var actors: Array[Node] = agent.get_tree().get_nodes_in_group(group)
	for actor in actors:
		if actor != agent:
			return actor

	return null

## get the required group to look for, based on team and enemy_or_ally
## returns empty if not found
func get_group(team: Constants.TEAM) -> String:
	var group: String = ""
	if enemy_or_ally == Constants.TARGET_OPTION.ally:
		group = Utility.get_enum_name(Constants.TEAM, team)

	elif enemy_or_ally == Constants.TARGET_OPTION.enemy:
		if team == Constants.TEAM.team1:
			group = Utility.get_enum_name(Constants.TEAM, Constants.TEAM.team2)

		elif team == Constants.TEAM.team2:
			group = Utility.get_enum_name(Constants.TEAM, Constants.TEAM.team1)

	return group
