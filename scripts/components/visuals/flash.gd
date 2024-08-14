@icon("res://assets/node_icons/flash.png")
## flash the attached sprite
class_name FlashComponent
extends Node


@export_group("Component Links")
@export var sprite: CanvasItem  ## the sprite this compononet will be flashing

@export_group("Details")
@export var material = preload("res://assets/effects/white_flash/white_flash_material.tres")  ## the material to alter the sprite
@export var flash_duration: = 0.2  ## duration of the flash


var original_sprite_material: Material  # store the original sprite's material to reset it after the flash
var timer: Timer = Timer.new()  # create a timer for the flash component to use


func _ready() -> void:
	# check for mandatory properties set in editor
	assert(sprite is CanvasItem, "Missing `sprite`.")

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
