## gets the [CombatActiveContainer]s from agent
@tool
extends BTAction

@export_group("Output")
@export var combat_actives_container_var: StringName = &"combat_actives_container"

func _generate_name() -> String:
	return "GetCombatActivesContainer: get combat actives container " + \
		"➜ %s as CombatActiveContainer" % [
		LimboUtility.decorate_var(combat_actives_container_var)
	]

func _tick(_delta: float) -> Status:
	if agent.combat_active_container is not CombatActiveContainer:
		return FAILURE

	blackboard.set_var(combat_actives_container_var, agent.combat_active_container)
	return SUCCESS



#TODO: need to load the info we need,
#		run once:
#			get actives
#		sequence:
#			get ready actives
#			get random one that has valid target in range
#			cast
