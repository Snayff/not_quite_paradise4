extends Area2D
class_name Hitbox

@export var health_component: HealthComponent

func _on_hit_detected(ability) -> void:
	if health_component:
		health_component.reduce(ability.damage)


	# apply knockback
	var parent = get_parent()
	if "velocity" in parent:
		parent.velocity = (global_position - ability.position).normalized() * ability.knockback_force
