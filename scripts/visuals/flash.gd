## flash the attached sprite
class_name FlashComponent
extends Node

## the material to alter the sprite
@export var material = preload("res://assets/effects/white_flash/white_flash_material.tres")
## the sprite this compononet will be flashing
@export var sprite: CanvasItem
## duration of the flash
@export var flash_duration: = 0.2

# store the original sprite's material to reset it after the flash
var original_sprite_material: Material

# create a timer for the flash component to use
var timer: Timer = Timer.new()

func _ready() -> void:
	# add the timer as a child of this component in order to use it
	add_child(timer)

	# store the original sprite material
	original_sprite_material = sprite.material

## apply the flash effect, before reverting to normal.
func activate():
	# set the sprite's material to the flash material
	sprite.material = material

	# start the timer (passing in the flash duration)
	timer.start(flash_duration)

	# wait until the timer times out
	await timer.timeout

	# set the sprite's material back to the original material that we stored
	sprite.material = original_sprite_material
