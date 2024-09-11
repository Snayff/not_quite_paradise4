## abc for delivery of effects and functionality.
@icon("res://assets/node_icons/abc.png")
class_name ABCProjectile
extends RigidBody2D


#region SIGNALS
## emitted when resolved
signal hit_valid_targets(hurtboxes: Array[HurtboxComponent])
#endregion


#region ON READY (for direct children only)
@onready var _hitbox: HitboxComponent = %HitboxComponent
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

# projectile data
## the team that caused this projectile to be created.
var _team: Constants.TEAM
## who the projectile can hit
var _valid_hit_option: Constants.TARGET_OPTION
## the animation for the projectile
var _sprite_frames: SpriteFrames
#endregion


#region FUNCS

##########################
####### LIFECYCLE ######
######################

func _ready() -> void:
	_sprite.stop()

	_has_run_ready = true

func setup(data: DataProjectile) -> void:
	if not _has_run_ready:
		push_error("AreaOfEffect: setup() called before _ready. ")

	_update_collisions()

## on hit functionality
##
## @virtual
func _on_hit(hurtbox: HurtboxComponent) -> void:
	push_error(
		"ABCProjectile: `_on_hit` called directly, but is virtual. Must be overriden by child."
	)

## queue_free
func _cleanup() -> void:
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
	Utility.update_body_collisions(self, _team, _valid_hit_option, _target_actor)
	Utility.update_hitbox_hurtbox_collision(_hitbox, _team, _valid_hit_option, _target_actor)

	#endregion

