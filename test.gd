extends RigidBody2D

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		add_constant_central_force(Vector2(100, 0))
