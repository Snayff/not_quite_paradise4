## Apply directional blur to a sprite
class_name MotionBlurComponent
extends ABCVisualEffect
# FIXME: shader's effect distorts the image, but doesnt work as intended.

#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
@export_group("Component Links")
@export var _movement_component: PhysicsMovementComponent
@export_group("Details")
@export var blur_direction: Vector2 = Vector2.ZERO  ## the direction of blur to apply
#endregion


#region VARS
var _material: ShaderMaterial = preload("res://shaders/motion_blur_material.tres")  ## the material to alter the sprite
var _original_sprite_material: Material  ## the sprite's original material to reset it after the flash
var _timer: Timer = Timer.new()  ## time the duration
var _is_active: bool = false  ## keep track of whether to update shader values
#endregion


#region FUNCS
func _ready() -> void:
	super._ready()

	# check for mandatory properties set in editor
	assert(_movement_component is PhysicsMovementComponent, "MotionBlurComponent: Misssing `_movement_component`.")

	_movement_component.velocity_calculated.connect(_update_direction)

	# add the timer as a child of this component in order to use it
	add_child(_timer)

	# store the original sprite material
	_original_sprite_material = _target_sprite.material

func _update_direction(movement_velocity: Vector2) -> void:
	blur_direction = movement_velocity.normalized()

func _process(delta: float) -> void:
	if blur_direction != Vector2.ZERO and not _is_active:
		activate()

	if _is_active:
		_material.set_shader_parameter("dir", blur_direction)
		_material.set_shader_parameter("quality", _amount)

## apply the blur effect, before reverting to normal.
func activate():
	_is_active = true

	# set the sprite's material to the flash material
	_target_sprite.material = _material

	# start the timer (passing in the flash duration)
	_timer.start(_duration)


func deactivate() -> void:
	_is_active = false

	# set the sprite's material back to the original material that we stored
	_target_sprite.material = _original_sprite_material






#endregion
