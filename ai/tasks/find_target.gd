## Stores the first [Actor] in the team_var. Found via group.
## Returns [code]FAILURE[/code] if the group contains 0 [Actor]s.
@tool
extends BTAction


@export_group("Input")
@export var team_var: StringName = &"team"
@export var target_option_var: StringName = &""
@export_group("Output")
@export var target_actor_var: StringName = &"target_actor"
@export_group("Config")
## set a target option to use to validate the targeting.
## if set, ignores target_option_var
@export var target_option_override: Constants.TARGET_OPTION


func _generate_name() -> String:
	var target_option_name: Variant
	if target_option_override != Constants.TARGET_OPTION.none:
		target_option_name = Utility.get_enum_name(Constants.TARGET_OPTION, target_option_override)
	else:
		target_option_name = LimboUtility.decorate_var(target_option_var)

	return "FindTarget: find target of type %s in %s ➜ %s as Actor" % [
		target_option_name,
		LimboUtility.decorate_var(team_var),
		LimboUtility.decorate_var(target_actor_var)
	]

func _tick(delta: float) -> Status:
	print("Run FindTarget")
	var target_actor: Actor = get_target()

	if target_actor is Actor:
		blackboard.set_var(target_actor_var, target_actor)
		print("FindTarget - SUCCESS")
		return SUCCESS
	else:
		print("FindTarget - FAILURE")
		return FAILURE

func get_target() -> Actor:
	var team: Constants.TEAM = blackboard.get_var(team_var)
	if team == null:
		return null

	var target_option: Variant
	if target_option_override != Constants.TARGET_OPTION.none:
		target_option = target_option_override
	else:
		target_option = blackboard.get_var(target_option_var)
		if target_option == null:
			print("Target option not found")
			return null
	if not target_option in [Constants.TARGET_OPTION.ally, Constants.TARGET_OPTION.enemy, Constants.TARGET_OPTION.self_]:
			print("Wrong target option")
			return null

	var group = get_group(team, target_option)
	if group == "":
		print("Group is empty")
		return null

	var actors: Array[Node] = agent.get_tree().get_nodes_in_group(group)
	for actor in actors:
		if Utility.target_is_valid(target_option, agent, actor):
			return actor

	print("No actor find")
	return null

## get the required group to look for, based on team and target_option
## returns empty if not found
func get_group(team: Constants.TEAM, target_option: Constants.TARGET_OPTION) -> String:
	var group: String = ""
	if target_option in [Constants.TARGET_OPTION.ally, Constants.TARGET_OPTION.self_]:
		group = Utility.get_enum_name(Constants.TEAM, team)

	elif target_option == Constants.TARGET_OPTION.enemy:
		if team == Constants.TEAM.team1:
			group = Utility.get_enum_name(Constants.TEAM, Constants.TEAM.team2)

		elif team == Constants.TEAM.team2:
			group = Utility.get_enum_name(Constants.TEAM, Constants.TEAM.team1)

	return group
