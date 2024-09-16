## flash the attached sprite
@icon("res://components/visuals/visual_effect_flash.png")
class_name VisualEffectFlash
extends ABCVisualEffect


var _material: ShaderMaterial = preload("res://shaders/white_flash_material.tres")  ## the material to alter the sprite
var _original_sprite_material: Material  ## the sprite's original material to reset it after the flash
var _timer: Timer = Timer.new()  ## time the duration


func _ready() -> void:
	super._ready()

	# add the timer as a child of this component in order to use it
	add_child(_timer)

	# store the original sprite material
	_original_sprite_material = _target_sprite.material

	_timer.timeout.connect(deactivate)

## apply the flash effect, before reverting to normal.
func activate():
	# set the sprite's material to the flash material
	_target_sprite.material = _material

	# start the timer (passing in the flash duration)
	_timer.start(_duration)

func deactivate() -> void:
	# set the sprite's material back to the original material that we stored
	_target_sprite.material = _original_sprite_material
