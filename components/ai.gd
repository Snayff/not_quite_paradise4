extends Node2D
class_name AIComponent

@export var target: CharacterBody2D
@export var movement: MovementComponent

func _process(delta: float) -> void:
	var direction: Vector2 = (get_parent().global_position - target.global_position).normalized()
	var force: ForceData = ForceData.new("walking", 10, direction, 1, false)
	movement.add_force(force, false)

