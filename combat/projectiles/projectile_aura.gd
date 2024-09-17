## A projectile that follows the target and loops an animation, repeatedly applying
## its effects on tick.
@icon("res://projectiles/projectile_aura.png")
class_name ProjectileAura
extends ABCProjectile


#region SIGNALS
signal hit_multiple_valid_targets(hurtboxes: Array[HurtboxComponent])
#endregion


#region ON READY (for direct children only)
@onready var _timer_tick: Timer = %TimerTick
@onready var _timer_lifetime: Timer = %TimerLifetime
#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
# @export_group("Details")
#endregion


#region VARS
## the animation frame on which to apply the effects
var _application_frame: int = 0
## how long the aura lasts before expiring.
var _lifetime: float
## has signalled out the named signal. we only want to share it once.
var _has_signalled_out_hit_valid_targets: bool = false
## if we have been enabled once already.
var _has_been_enabled: bool = false
## all the hurtboxes hit by this. used to prevent hitting same target twice
var _hurtboxes_hit: Array[HurtboxComponent] = []
#endregion


#region FUNCS

##########################
####### LIFECYCLE ######
######################

func _ready() -> void:
	super._ready()

	# on each frame, check if we should enable
	_sprite.frame_changed.connect(_check_frame_and_conditionally_enable)

	# when animation ends, queue up playing next animation
	_sprite.animation_looped.connect(_restart)
	_sprite.animation_finished.connect(_restart)

	# link hitbox signal to our on_hit
	_hitbox.hit_hurtbox.connect(_on_hit)

	visible = false

## complete setup process and trigger activate
func setup(spawn_pos: Vector2, data: DataProjectile) -> void:
	super.setup(spawn_pos, data)

	assert(
		data.lifetime > 0,
		"ProjectileAura:	`lifetime` cannot be <= 0, otherwise will never exist."
	)

	# do after super.setup as that's where sprite_frames are assigned
	assert(
		_application_frame <= _sprite.sprite_frames.get_frame_count("default"),
		"ProjectileAura: `_application_frame` is higher than the total number of frames."
	)

	if _sprite.sprite_frames.get_animation_speed("default") > 40:
		push_warning(
			"ProjectileAura: animation is fast enough that we might be \
			too fast to register the hits."
		)

	_application_frame = data.aura_application_frame
	_lifetime = data.lifetime

	# connect timers
	_timer_lifetime.timeout.connect(_terminate)
	_timer_tick.timeout.connect(activate)

	# start lifetime countdown
	_timer_lifetime.start(_lifetime)

	activate()

func activate() -> void:
	_sprite.play()

	visible = true

	# call now to account for application frame being 0
	_check_frame_and_conditionally_enable()


func _process(_delta: float) -> void:
	if _target_actor is Actor:
		global_position = _target_actor.global_position


## if target is valid and not already hit, log the target for later signaling (when animation ends)
func _on_hit(hurtbox: HurtboxComponent) -> void:
	if Utility.target_is_valid(_valid_hit_option, _hitbox.originator, hurtbox.root):
		if hurtbox in _hurtboxes_hit:
			return
		_hurtboxes_hit.append(hurtbox)

## restart the process, i.e. loop, after the delay
func _restart() -> void:
	_sprite.stop()
	visible = false

	# trigger timer, which will trigger restart when done
	_timer_tick.start(Constants.AURA_TICK_RATE)

	# reset flags
	_has_signalled_out_hit_valid_targets = false
	_has_been_enabled = false

######################
####### PUBLIC ######
####################

########################
####### PRIVATE #######
######################

## enable hitbox if current frame is the application frame, otherwise disable.
## When disabling we signal out hit_multiple_valid_targets to inform of hit targets
func _check_frame_and_conditionally_enable() -> void:
	if _sprite.frame == _application_frame:
		_set_hitbox_disabled(false)
		_set_collision_disabled(false)
		_has_been_enabled = true

	# FIXME: if an animation is too fast then we disable before we've had chance to register
	#	this is exacerbated due to the disabled status being a deferred call
	elif _has_been_enabled and not _has_signalled_out_hit_valid_targets:
		hit_multiple_valid_targets.emit(_hurtboxes_hit)
		_set_hitbox_disabled(true)
		_set_collision_disabled(true)
		_has_signalled_out_hit_valid_targets = true


## turns off body coliisions and updates hitbox collisions to align to team etc.
func _update_collisions() -> void:
	# NOTE: if body collision layer is on then the aoe is pushed to the outer edge of the collision
	Utility.update_body_collisions(self, _team, _valid_hit_option, _target_actor, false, false)
	Utility.update_hitbox_hurtbox_collision(_hitbox, _team, _valid_hit_option, _target_actor, false)

#endregion
