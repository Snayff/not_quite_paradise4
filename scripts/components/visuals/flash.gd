## flash the attached sprite
class_name FlashComponent
extends VisualEffect


@export_group("Details")
@export var _material: ShaderMaterial = preload("res://assets/effects/white_flash/white_flash_material.tres")  ## the material to alter the sprite


var _original_sprite_material: Material  # store the original sprite's material to reset it after the flash
var _timer: Timer = Timer.new()  # create a timer for the flash component to use


func _ready() -> void:
	super._ready()

	# add the timer as a child of this component in order to use it
	add_child(_timer)

	# store the original sprite material
	_original_sprite_material = _target_sprite.material

## apply the flash effect, before reverting to normal.
func activate():
	# set the sprite's material to the flash material
	_target_sprite.material = _material

	# start the timer (passing in the flash duration)
	_timer.start(_duration)

	# wait until the timer times out
	await _timer.timeout

	# set the sprite's material back to the original material that we stored
	_target_sprite.material = _original_sprite_material
