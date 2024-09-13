## a projectile without any physical interaction with the world
##
## still have collisions etc., but doesnt naturally affect the physical world just by existing, a la RigidBody.
@icon("res://assets/node_icons/visual_projectile.png")
class_name VisualProjectile
extends AnimatedSprite2D


#region SIGNALS
signal hit_valid_target(hurtbox: HurtboxComponent)
signal died
#endregion


#region ON READY
@onready var _on_hit_effect_spawner: SpawnerComponent = %OnHitEffectSpawner
@onready var _hitbox: HitboxComponent = %HitboxComponent
@onready var _movement_component: MovementComponent = %MovementComponent
@onready var _death_trigger: DeathTrigger = %DeathTrigger  ## to propogate died signal and to allow triggering manually
@onready var _travel_range_supply: SupplyComponent = %SupplyContainer.get_supply(Constants.SUPPLY_TYPE.health)
#endregion


#region EXPORTS
#@export_group("Component Links")
#@export_group("Config")

#endregion


#region VARS
var _target_actor: CombatActor
var _target_position: Vector2
var _team: Constants.TEAM
var _valid_effect_option: Constants.TARGET_OPTION  ## who the effect chain can apply to
var _has_run_ready: bool = false  ## has completed _ready()

#endregion


#region FUNCS
func _ready() -> void:
	_hitbox.hit_hurtbox.connect(_on_hit)
	hit_valid_target.connect(_death_trigger.activate.unbind(1))
	_death_trigger.died.connect(func(): died.emit())

	_has_run_ready = true

## run setup process
func setup(
	travel_range: float,
	team: Constants.TEAM,
	effect_chain_target: Constants.TARGET_OPTION,
	target_actor: CombatActor = null,
	target_position: Vector2 = Vector2.ZERO,
	size: float = -1
	) -> void:

	if not _has_run_ready:
		push_error("VisualProjectile: setup() called before _ready. ")

	assert(travel_range is float, "VisualProjectile: `travel_range` is missing." )
	assert(team is Constants.TEAM, "VisualProjectile: `team` is missing." )
	assert(effect_chain_target is Constants.TARGET_OPTION, "VisualProjectile: `effect_chain_target` is missing." )

	set_travel_range(travel_range)
	_team = team
	_valid_effect_option = effect_chain_target
	set_target(target_actor, target_position)

	if size != -1:
		# scale the aoe scene, which will then affect all children, inc. the collision shape
		var shape: Shape2D = _hitbox.get_node("CollisionShape2D").shape
		var ratio: float = Utility.get_ratio_desired_vs_current(size, shape)
		scale = Vector2(ratio, ratio)

	_update_collisions()

## if target is valid, signal out hit_valid_target
func _on_hit(hurtbox: HurtboxComponent) -> void:
	if Utility.target_is_valid(_valid_effect_option, _hitbox.originator, hurtbox.root, _target_actor):
		# turn off hitbox
		_hitbox.set_disabled_status(true)

		# emit signals
		hit_valid_target.emit(hurtbox)

		# spawn on hit effect
		_on_hit_effect_spawner.spawn_scene(global_position)

		# trigger death trigger
		_death_trigger.activate()

## wrapper for setting movement component's target.
##
## Can give either an actor or a position. If both are given only actor is used.
## collisions may need updating after this.
func set_target(actor: CombatActor = null, target_position: Vector2 = Vector2.ZERO) -> void:
	if actor is CombatActor:
		_set_target_actor(actor)
	elif target_position is Vector2:
		_set_target_position(target_position)

func _set_target_actor(actor: CombatActor) -> void:
	_target_actor = actor
	_movement_component.target_actor = actor

## wrapper for setting movement component's target position
func _set_target_position(target_position: Vector2) -> void:
	_target_position = target_position
	_movement_component.target_position = target_position

func set_travel_range(travel_range: float) -> void:
	@warning_ignore("narrowing_conversion")  # happy with reduced precision
	_travel_range_supply.set_value(travel_range)
	@warning_ignore("narrowing_conversion")  # happy with reduced precision
	_travel_range_supply.max_value = travel_range

## updates all collisions to reflect current target, team etc.
func _update_collisions() -> void:
	Utility.update_hitbox_hurtbox_collision(_hitbox, _team, _valid_effect_option, _target_actor)

#endregion
