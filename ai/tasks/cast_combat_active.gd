## cast a [CombatActive] via a [CombatActiveContainer]
@tool
extends BTAction

@export_group("Input")
@export var combat_actives_container_var: StringName = &"combat_actives_container"
@export var combat_active_var: StringName = &"combat_active"

func _generate_name() -> String:
	return 	"CastCombatActive: cast combat active %s " % [
			LimboUtility.decorate_var(combat_active_var)
		]

func _tick(delta: float) -> Status:
	var active: CombatActive = blackboard.get_var(combat_active_var) as CombatActive
	var active_container: CombatActiveContainer = blackboard.get_var(combat_actives_container_var) \
		as CombatActiveContainer
	if active_container is not CombatActiveContainer or active is not CombatActive:
		return FAILURE

	var was_successful: bool = active_container.cast_ready_active(active.combat_active_name)
	if was_successful:
		return SUCCESS
	else:
		return FAILURE


	#var active_container: CombatActiveContainer = blackboard.get_var(combat_actives_container_var) \
		#as CombatActiveContainer
	#if active_container is not CombatActiveContainer:
		#return FAILURE
#
	#var active: CombatActive = active_container.get_random_ready_active()
	#if active is not CombatActive:
		#return FAILURE
#
	#blackboard.set_var(combat_actives_container_var, agent.combat_active_container.get_all_actives())
	#return SUCCESS
