## flash the attached sprite
@icon("res://assets/node_icons/flash.png")
class_name FlashComponent
extends Node


@export_group("Component Links")
@export var _sprite: CanvasItem  ## the sprite this compononet will be flashing. @REQUIRED.

@export_group("Details")
@export var _material: ShaderMaterial = preload("res://assets/effects/white_flash/white_flash_material.tres")  ## the material to alter the sprite
@export var _duration: float = 0.2  ## duration of the flash


var _original_sprite_material: Material  # store the original sprite's material to reset it after the flash
var _timer: Timer = Timer.new()  # create a timer for the flash component to use


func _ready() -> void:
	# check for mandatory properties set in editor
	assert(_sprite is CanvasItem, "Missing `sprite`.")

	# add the timer as a child of this component in order to use it
	add_child(_timer)

	# store the original sprite material
	_original_sprite_material = _sprite.material

## apply the flash effect, before reverting to normal.
func activate():
	# set the sprite's material to the flash material
	_sprite.material = _material

	# start the timer (passing in the flash duration)
	_timer.start(_duration)

	# wait until the timer times out
	await _timer.timeout

	# set the sprite's material back to the original material that we stored
	_sprite.material = _original_sprite_material
