## shake a sprite's visual position
class_name ShakeComponent
extends Node

# You should shake the sprite and not the root node or you'll get unexpected behavior
# since we are manipulating the position of the node and moving it to 0,0

## the sprite to apply the shake to
@export var sprite: Node2D

## the max position offset in the shake
@export var amount: int = 2.0

## how long to shake for
@export var duration: float = 0.4

# store the current amount we are shaking the node (this value will decrease over time)
var _current_shake = 0

## apply the shake effect
func activate():
	# Set the shake to the shake amount (shake is the value used in the process function to
	# shake the node)
	_current_shake = amount

	# Create a tween
	var tween = create_tween()

	# Tween the shake value from current down to 0 over the shake duration
	tween.tween_property(self, "_current_shake", 0.0, duration).from_current()

func _physics_process(delta: float) -> void:
	# Manipulate the position of the node by the shake amount every physics frame
	# Use randf_range to pick a random x and y value using the shake value
	sprite.position = Vector2(randf_range(-_current_shake, _current_shake), randf_range(-_current_shake, _current_shake))
