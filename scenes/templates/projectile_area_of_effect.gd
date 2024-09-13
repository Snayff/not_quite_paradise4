## A projectile that does not move, hits 1 or more bodies in an area. self terminates at end of
## animation.
@icon("res://assets/node_icons/projectile_aoe.png")
class_name ProjectileAreaOfEffect
extends ABCProjectile


#region SIGNALS
signal hit_valid_targets(hurtboxes: Array[HurtboxComponent])
#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
# @export_group("Details")
#endregion


#region VARS
## all the hurtboxes hit by this. used to prevent hitting same target twice
var _hurtboxes_hit: Array[HurtboxComponent] = []
## the animation frame on which to apply the effects
var _application_frame: int = 0
## has signalled out the named signal. we only want to share it once.
var _has_signalled_out_hit_valid_targets: bool = false
## if we have been enabled once already.
var _has_been_enabled: bool = false
#endregion


#region FUNCS

##########################
####### LIFECYCLE ######
######################

func _ready() -> void:
	super._ready()

	_sprite.frame_changed.connect(_check_frame_and_conditionally_enable)

	_sprite.animation_looped.connect(_terminate)
	_sprite.animation_finished.connect(_terminate)

	# link hitbox signal to our on_hit
	_hitbox.hit_hurtbox.connect(_on_hit)

	visible = false

func setup(spawn_pos: Vector2, data: DataProjectile) -> void:
	super.setup(spawn_pos, data)

	# do after super.setup as that's where sprite_frames are assigned
	assert(
		_application_frame <= _sprite.sprite_frames.get_frame_count("default"),
		"AreaOfEffect:	`_application_frame` is higher than the total number of frames."
	)

	if _sprite.sprite_frames.get_animation_speed("default") > 40:
		push_warning("AreaOfEffect: animation is fast enough that we might be too fast to register the hits.")

	_application_frame = data.application_frame

	activate()

func activate() -> void:
	_sprite.play()

	visible = true

	# call now to account for application frame being 0
	_check_frame_and_conditionally_enable()

## if target is valid and not already hit, log the target for later signaling (when animation ends)
func _on_hit(hurtbox: HurtboxComponent) -> void:
	if Utility.target_is_valid(_valid_hit_option, _hitbox.originator, hurtbox.root):
		if hurtbox in _hurtboxes_hit:
			return
		_hurtboxes_hit.append(hurtbox)

######################
####### PUBLIC ######
####################

########################
####### PRIVATE #######
######################

## enable hitbox if current frame is the application frame, otherwise disable.
## When disabling we signal out hit_valid_targets to inform of hit targets
func _check_frame_and_conditionally_enable() -> void:
	if _sprite.frame == _application_frame:
		_set_hitbox_disabled(false)
		_set_collision_disabled(false)
		_has_been_enabled = true

	# FIXME: if an animation is too fast then we disable before we've had chance to register
	#	this is exacerbated due to the disabled status being a deferred call
	elif _has_been_enabled and not _has_signalled_out_hit_valid_targets:
		hit_valid_targets.emit(_hurtboxes_hit)
		_set_hitbox_disabled(true)
		_set_collision_disabled(true)
		_has_signalled_out_hit_valid_targets = true

#endregion
