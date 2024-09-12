## abc for delivery of effects and functionality.
@icon("res://assets/node_icons/abc.png")
class_name ABCProjectile
extends RigidBody2D


#region SIGNALS
## when the projectile hits _cleanup and self_terminates, for any reason
signal died
#endregion


#region ON READY (for direct children only)
@onready var _hitbox: HitboxComponent = $HitboxComponent
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
# @export_group("Details")
#endregion


#region VARS
# internals
var _target_actor: CombatActor
## has completed _ready()
var _has_run_ready: bool = false
## has signalled out the named signal. we only want to share it once.
var _has_signalled_out_hit_valid_targets: bool = false
## how many bodies hit so far. only tracks valid hits.
var _num_bodies_hit: int = 0

# projectile data
## the team that caused this projectile to be created.
var _team: Constants.TEAM
## who the projectile can hit
var _valid_hit_option: Constants.TARGET_OPTION
## the max number of valid bodies that can be hit
var _max_bodies_can_hit: int
#endregion


#region FUNCS

##########################
####### LIFECYCLE ######
######################

func _ready() -> void:
	_sprite.stop()
	_set_collision_disabled(true)
	_set_hitbox_disabled(true)

	_has_run_ready = true

func setup(data: DataProjectile) -> void:
	if not _has_run_ready:
		push_error("ABCProjectile: setup() called before _ready. ")

	assert(
		data.team is Constants.TEAM,
		"ABCProjectile: `team` is missing."
	)
	assert(
		data.valid_hit_option is Constants.TARGET_OPTION,
		"ABCProjectile: `valid_hit_option` is missing."
	)
	assert(
		data.max_bodies_can_hit is int and data.max_bodies_can_hit > 0,
		"ABCProjectile: `max_bodies_can_hit` is missing or invalid."
	)
	assert(
		data.sprite_frames is SpriteFrames,
		"ABCProjectile: `sprite_frames` is missing."
	)


	_team = data.team
	_valid_hit_option = data.valid_hit_option
	_max_bodies_can_hit = data.max_bodies_can_hit

	_sprite.sprite_frames = data.sprite_frames

	if data.size > 0:
		_resize(data.size)

	_update_collisions()

## on hit functionality
##
## @virtual
@warning_ignore("unused_parameter")  # virtual, so obv not used
func _on_hit(hurtbox: HurtboxComponent) -> void:
	push_error(
		"ABCProjectile: `_on_hit` called directly, but is virtual. Must be overriden by child."
	)

## self-terminate. inform of death via died signal.
func _terminate() -> void:
	died.emit()
	queue_free()

######################
####### PUBLIC ######
####################

## enable self and begin to act
##
## @virtual
func activate() -> void:
	push_error(
		"ABCProjectile: `activate` called directly, but is virtual. Must be overriden by child."
	)

## set the actor the projectile should target.
func set_target_actor(actor: CombatActor) -> void:
	_target_actor = actor


########################
####### PRIVATE #######
######################

## enable or diasble the collisions. Deferred call.
##
## true disables the projectile's collisions.
func _set_collision_disabled(is_disabled: bool) -> void:
	var shape: CollisionShape2D = get_node("CollisionShape2D")
	shape.set_deferred("disabled", is_disabled)

## enable or diasble the hitbox. Deferred call.
##
## true disables the hitbox.
func _set_hitbox_disabled(is_disabled: bool) -> void:
	_hitbox.set_disabled_status(is_disabled)

## scale to a new size
func _resize(size: float) -> void:
	var shape: Shape2D = get_node("CollisionShape2D").shape
	var ratio: float = Utility.get_ratio_desired_vs_current(size, shape)

	scale = Vector2(ratio, ratio)

## updates all collisions to reflect current target, team etc.
func _update_collisions() -> void:
	Utility.update_body_collisions(self, _team, _valid_hit_option, _target_actor, false)
	Utility.update_hitbox_hurtbox_collision(_hitbox, _team, _valid_hit_option, _target_actor, false)

	#endregion
