## gets a random ready [CombatActive]s from the [CombatActiveContainer] held in
## [member combat_actives_container_var]
@tool
extends BTAction

@export_group("Input")
@export var combat_actives_container_var: StringName = &"combat_actives_container"
@export_group("Output")
@export var combat_active_var: StringName = &"combat_active"
@export var combat_active_range_var: StringName = &"combat_active_range"
@export var combat_active_target_option_var: StringName = &"combat_active_target_option"

func _generate_name() -> String:
	return (
		"GetReadyCombatActives: get a random, ready combat active from %s " +
		"➜ %s as CombatActive, %s as float, %s as Constants.TARGET_OPTION"
		) % [
			LimboUtility.decorate_var(combat_actives_container_var),
			LimboUtility.decorate_var(combat_active_var),
			LimboUtility.decorate_var(combat_active_range_var),
			LimboUtility.decorate_var(combat_active_target_option_var)
		]

func _tick(_delta: float) -> Status:
	#print("Run GetReadyCombatActives")
	var active_container = blackboard.get_var(combat_actives_container_var) \
		as CombatActiveContainer
	if active_container is not CombatActiveContainer:
		#print("Active container not found")
		#print("GetReadyCombatActives - SUCCESS")
		return FAILURE

	var active: CombatActive = active_container.get_random_ready_active()
	if active is not CombatActive:
		#print("Active not found")
		#print("GetReadyCombatActives - FAILURE")
		return FAILURE

	blackboard.set_var(combat_active_var, active)
	blackboard.set_var(combat_active_range_var, active.get_range())
	blackboard.set_var(combat_active_target_option_var, active.valid_target_option)
	return SUCCESS
