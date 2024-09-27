## gets a random ready [CombatActive]s from the [CombatActiveContainer] held in
## [member combat_actives_container_var]
@tool
extends BTAction

@export_group("Input")
@export var combat_actives_container_var: StringName = &"combat_actives_container"
@export_group("Output")
@export var combat_active_var: StringName = &"combat_active"

func _generate_name() -> String:
	return (
		"GetReadyCombatActives: get a random, ready combat active from %s " +
		"➜ %s as CombatActive"
		) % [
			LimboUtility.decorate_var(combat_actives_container_var),
			LimboUtility.decorate_var(combat_active_var)
		]

func _tick(delta: float) -> Status:
	var active_container = blackboard.get_var(combat_actives_container_var) \
		as CombatActiveContainer
	if active_container is not CombatActiveContainer:
		return FAILURE

	var active: CombatActive = active_container.get_random_ready_active()
	if active is not CombatActive:
		return FAILURE

	blackboard.set_var(combat_active_var, active)
	return SUCCESS
