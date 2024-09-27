## gets the [Constants.TEAM] from [Allegiance] on agent
@tool
extends BTAction

## blackboard var for team
@export var team_var: StringName = &"team"

func _generate_name() -> String:
	return "GetTeam: get team ➜ %s as Constants.TEAM" % [
		LimboUtility.decorate_var(team_var)
	]

func _tick(_delta: float) -> Status:
	if agent.allegiance is not Allegiance:
		return FAILURE

	blackboard.set_var(team_var, agent.allegiance.team)
	return SUCCESS
