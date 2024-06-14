extends Area2D
class_name Hitbox

@export var health_component: HealthComponent
@export var movement_component: MovementComponent

func _on_hit_detected(ability) -> void:
	if health_component:
		health_component.reduce(ability.damage)


	# apply knockback
	var parent = get_parent()
	if "velocity" in parent and ability.knockback_force:
		movement_component.add_force(ability.knockback_force, true)
