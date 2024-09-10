## An aesthetic only effect. As such, should have no functional side effects.
@icon("res://assets/node_icons/visual_effect.png")
class_name VisualEffect
extends Node


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
@export_group("Component Links")
@export var _target_sprite: CanvasItem  ## the sprite to apply the effect to
@export_group("Details")
@warning_ignore("unused_private_class_variable")  # used by children
@export var _amount: float = 2.0
@warning_ignore("unused_private_class_variable")  # used by children
@export var _duration: float = 0.4
#endregion


#region VARS

#endregion


#region FUNCS
func _ready() -> void:
	# try and find a sprite if we dont have one
	if _target_sprite is not CanvasItem:
		var sprite = get_parent().get_node_or_null("AnimatedSprite2D")
		if sprite != null:
			_target_sprite = sprite
		else:
			sprite = get_parent().get_node_or_null("Sprite2D")
			if sprite != null:
				_target_sprite = sprite

	# check for mandatory properties set in editor
	assert(_target_sprite is CanvasItem, "VisualEffect: Misssing `_target_sprite`.")

## @virtual activate the effect on the _target_sprite
func activate() -> void:
	push_error(
		"VisualEffect: `activate` called directly, but is virtual. Must be overriden by child."
	)
	pass

## @virtual deactivate the effect on the _target_sprite.
## usually called at end of duration automiatically.
func deactivate() -> void:
	push_error(
		"VisualEffect: `activate` called directly, but is virtual. Must be overriden by child."
	)
	pass


#endregion
