extends Node2D
class_name MovementComponent

var _forces: Dictionary = {}


func _physics_process(delta: float) -> void:
	_apply_forces()


func _process(delta: float) -> void:
	_update_forces(delta)


func _update_forces(delta: float) -> void:
	var forces_to_delete: Array[String] = []

	for force in _forces:
		force.duration -= delta
		if force.duration <= 0:
			forces_to_delete.append(force.name)

		if force.reduces_over_time:
			force.amount = lerp(force.amount, 0, force.duration / force.max_duration)

	# delete expired forces
	if forces_to_delete.size() > 0:
		for force_name in forces_to_delete:
			_forces.erase(force_name)


func _apply_forces() -> void:
	var direction: Vector2 = Vector2.ZERO
	for force: ForceData in _forces:
		direction += force.direction.normalized() * force.amount

	if "velocity" in get_parent():
		get_parent().velocity = direction


## if add_values_to_existing == false then overwrites existing values for the given name, if there are any.
func add_force(force: ForceData, add_values_to_existing: bool) -> void:
	if force.name in _forces and add_values_to_existing:
		var existing_force: ForceData = _forces[name]
		existing_force.amount += force.amount
		existing_force.duration += force.duration
		existing_force.direction = (existing_force.direction + force.direction) / 2
	else:
		_forces[force.name] = force
