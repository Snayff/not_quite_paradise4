## class desc
@icon("res://assets/node_icons/area_of_effect.png")
class_name AreaOfEffect
extends AnimatedSprite2D


#region SIGNALS
signal hit_valid_targets(bodies: Array[PhysicsBody2D])
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
var _valid_effect_option: Constants.TARGET_OPTION  ## who the effect chain can apply to. expected to be set by the combat active
var _team: Constants.TEAM  ## the team that caused this aoe to be created. expected to be set by the combat active
#endregion


#region FUNCS
func _ready() -> void:
	frame_changed.connect(_conditionally_enable)

	animation_looped.connect(_cleanup)
	animation_finished.connect(_cleanup)

	_hitbox.set_disabled_status(true)
	_hitbox.hit_hurtbox.connect(_on_hit)

## run setup process
func setup(new_position: Vector2, team: Constants.TEAM, valid_effect_option: Constants.TARGET_OPTION) -> void:
	global_position = new_position
	_team = team
	_valid_effect_option = valid_effect_option

## if current sprite frame is at the _application_frame then trigger _enable()
func _conditionally_enable() -> void:
	if frame == _application_frame:
		_enable()

## enable the hitbox
func _enable() -> void:
	Utility.update_hitbox_hurtbox_collision(_hitbox, _team, _valid_effect_option)
	_hitbox.set_disabled_status(false)

## if target is valid and not already hit, log the target for later signaling (when animation ends)
func _on_hit(hurtbox: HurtboxComponent) -> void:
	if Utility.target_is_valid(_valid_effect_option, _hitbox.originator, hurtbox.root):
		if hurtbox in _bodies_hit:
			return
		_bodies_hit.append(hurtbox.root)

## signal out hit_valid_targets and queue_free
func _cleanup() -> void:
	hit_valid_targets.emit(_bodies_hit)

#endregion
