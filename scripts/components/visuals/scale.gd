## scale a sprite to a specified size and then back again
class_name ScaleComponent
extends VisualEffect

@export_group("Details")
@export var _scale_amount = Vector2(1.5, 1.5)  ## the scale amount (as a vector)

var _original_scale_value: Vector2 = Vector2.ZERO

## apply the scale effect, before reverting to normal.
func activate() -> void:
	_original_scale_value = _target_sprite.scale

	# define transition type and easing type
	var tween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

	# scale current scale to the scale amount (in 1/10th of the scale duration)
	tween.tween_property(_target_sprite, "scale", _scale_amount, _duration * 0.1).from_current()

	# scale back to original value of 1 for the other 9/10ths of the scale duration
	tween.tween_property(
		_target_sprite,
		"scale",
		_original_scale_value,
		_duration * 0.9
	).from(_scale_amount)
