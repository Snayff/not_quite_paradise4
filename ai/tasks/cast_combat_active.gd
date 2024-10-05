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

func _tick(_delta: float) -> Status:
	var active: CombatActive = blackboard.get_var(combat_active_var) as CombatActive
	var active_container: CombatActiveContainer = blackboard.get_var(combat_actives_container_var) \
		as CombatActiveContainer
	if active_container is not CombatActiveContainer or active is not CombatActive:
		return FAILURE

	var was_successful: bool = active_container.cast_ready_active(active.f_name)
	if was_successful:
		return SUCCESS
	else:
		return FAILURE
