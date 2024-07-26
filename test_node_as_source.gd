extends Node2D
@onready var rigid_body_2d: RigidBody2D = $RigidBody2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		rigid_body_2d.add_constant_central_force(Vector2(100, 0))
