## class desc
@icon("res://assets/node_icons/area_of_effect.png")
class_name AreaOfEffect
extends AnimatedSprite2D


#region SIGNALS
signal hit_valid_target(hurtbox: HurtboxComponent)
#endregion


#region ON READY (for direct children only)
@onready var _hitbox: HitboxComponent = %HitboxComponent

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
@export_group("Details")
@export var _application_frame: int = 0  ## the animation frame on which to apply the effects
#endregion


#region VARS
var _bodies_hit: Array[PhysicsBody2D] = []  ## everyone hit by this. used to prevent hitting same target twice
# config - these are set by the combat active
var valid_effect_option: Constants.TARGET_OPTION  ## who the effect chain can apply to

#endregion


#region FUNCS
func _ready() -> void:
	frame_changed.connect(_attempt_enable)
	animation_looped.connect(func(): queue_free())
	animation_finished.connect(func(): queue_free())

	_hitbox.set_disabled_status(true)
	_hitbox.hit_hurtbox.connect(_on_hit)

## if current sprite frame is at the _application_frame then trigger _enable()
func _attempt_enable() -> void:
	if frame == _application_frame:
		_enable()

## enable the hitbox
func _enable() -> void:
	_hitbox.set_disabled_status(false)

## if target is valid and not already hit, signal out hit_valid_target
func _on_hit(hurtbox: HurtboxComponent) -> void:
	if Utility.target_is_valid(valid_effect_option, _hitbox.originator, hurtbox.root):
		if hurtbox in _bodies_hit:
			return
		_bodies_hit.append(hurtbox)

		hurtbox.hurt.emit(self)
		hit_valid_target.emit(hurtbox)


#endregion
