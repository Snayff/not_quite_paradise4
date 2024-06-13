extends Node2D
class_name HealthComponent

@export var max_health: float = 10.0
var health: float = 0.0

func _ready() -> void:
	health = max_health


func reduce(amount: float) -> void:
	health -= amount

	if health <= 0:
		_on_health_depleted


func _on_health_depleted() -> void:
	get_parent().queue_free()
