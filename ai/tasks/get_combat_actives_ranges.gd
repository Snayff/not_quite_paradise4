## gets the smallest and largest ranges of actives from [combat_actives_container_var]
@tool
extends BTAction


@export_group("Input")
@export var combat_actives_container_var: StringName = &"combat_actives_container"
@export_group("Output")
@export var smallest_range_var: StringName = &"smallest_range"
@export var largest_range_var: StringName = &"largest_range"

func _generate_name() -> String:
	return (
		"GetCombatActivesRanges: get smallest and largest ranges from %s " +
		"➜ %s as float, %s as float"
		) % [
			LimboUtility.decorate_var(combat_actives_container_var),
			LimboUtility.decorate_var(smallest_range_var),
			LimboUtility.decorate_var(largest_range_var),
		]

func _tick(_delta: float) -> Status:
	var active_container: CombatActiveContainer = blackboard.get_var(combat_actives_container_var) \
		as CombatActiveContainer
	if active_container is not CombatActiveContainer:
		return FAILURE

	if active_container.get_all_actives().size() == 0:
		return FAILURE

	var range_array: Array[float] = active_container.get_ranges()
	blackboard.set_var(smallest_range_var, range_array[0])
	blackboard.set_var(largest_range_var, range_array[1])

	return SUCCESS
