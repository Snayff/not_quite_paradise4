## an AnimatedSprite2D that frees itself at the end of the animation loop.
class_name OneShotAnimation
extends AnimatedSprite2D


func _ready() -> void:
	# Free this node when the animation is finished
	animation_finished.connect(queue_free)
	animation_looped.connect(queue_free)

	play("default")
