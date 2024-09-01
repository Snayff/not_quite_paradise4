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
var _has_run_ready: bool = false  ## has completed _ready()
var _has_signalled_out_hit_valid_targets: bool = false  ## has signalled out the named signal. we only want to share it once.
var _has_been_enabled: bool = false  ## if we have been enabled once already.
#endregion


#region FUNCS
func _ready() -> void:
	frame_changed.connect(_check_frame_and_conditionally_enable)

	animation_looped.connect(_cleanup)
	animation_finished.connect(_cleanup)

	_hitbox.set_disabled_status(true)
	_hitbox.hit_hurtbox.connect(_on_hit)

	_has_run_ready = true

## run setup process
func setup(new_position: Vector2, team: Constants.TEAM, valid_effect_option: Constants.TARGET_OPTION, radius: float = -1) -> void:
	if not _has_run_ready:
		push_error("AreaOfEffect: setup() called before _ready. ")

	assert(new_position is Vector2, "AreaOfEffect: new_position is missing." )
	assert(team is Constants.TEAM, "AreaOfEffect: team is missing." )
	assert(valid_effect_option is Constants.TARGET_OPTION, "AreaOfEffect: valid_effect_option is missing." )

	global_position = new_position
	_team = team
	_valid_effect_option = valid_effect_option

	Utility.update_hitbox_hurtbox_collision(_hitbox, _team, _valid_effect_option)

	if radius != -1:
		# get current shape radius
		var shape_radius: float = _hitbox.get_node("CollisionShape2D").shape.radius

		# compare to desired radius
		var ratio: float = shape_radius / radius

		# scale the aoe scene, which will then affect all children, inc. the collision shape
		scale = Vector2(ratio, ratio)

## enable hitbox if current frame is the application frame, otherwise disable. When disabling we signal out hit_valid_targets to inform of hit targets
func _check_frame_and_conditionally_enable() -> void:
	if frame == _application_frame:
		_set_hitbox_disabled_status(false)
		_has_been_enabled = true

	elif _has_been_enabled and not _has_signalled_out_hit_valid_targets:
		hit_valid_targets.emit(_bodies_hit)
		_set_hitbox_disabled_status(true)
		_has_signalled_out_hit_valid_targets = true


## enable or diasble the hitbox.
##
## true disables the hitbox.
func _set_hitbox_disabled_status(is_disabled: bool) -> void:
	_hitbox.set_disabled_status(is_disabled)


## if target is valid and not already hit, log the target for later signaling (when animation ends)
func _on_hit(hurtbox: HurtboxComponent) -> void:
	if Utility.target_is_valid(_valid_effect_option, _hitbox.originator, hurtbox.root):
		if hurtbox.root in _bodies_hit:
			return
		_bodies_hit.append(hurtbox.root)

## queue_free
func _cleanup() -> void:
	queue_free()

#endregion
