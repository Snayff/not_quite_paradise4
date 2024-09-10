## an AnimatedSprite2D that is freed at the end of its animation loop.
class_name OneShotAnimation
extends AnimatedSprite2D


func _ready() -> void:
	animation_finished.connect(queue_free)
	animation_looped.connect(queue_free)

	play("default")
