## A projectile that moves, expires on reaching end of travel range,
## triggers effects on hit and on death
@icon("res://assets/node_icons/projectile_throwable.png")
class_name ProjectileThrowable
extends ABCProjectile


#region SIGNALS
## emitted when resolved
signal hit_valid_target(hurtbox: HurtboxComponent)
#endregion


#region ON READY (for direct children only)
@onready var _on_hit_effect_spawner: SpawnerComponent = $OnHitEffectSpawner
@onready var _on_death_effect_spawner: SpawnerComponent = $OnDeathEffectSpawner
@onready var _supply_container: SupplyContainerComponent = $SupplyContainerComponent
@onready var _death_trigger: DeathTrigger = $DeathTrigger
@onready var _movement_component: PhysicsMovementComponent = $PhysicsMovementComponent

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
# @export_group("Details")
#endregion


#region VARS
## the amount of stamina we can drain before expiry
var _travel_range: float
## how fast we travel
var _move_speed: float
## whether we track targets movement and follow, or not
var _is_homing: bool

#endregion

# TODO: need to spend down stamina on movement

#region FUNCS
func _ready() -> void:
	super._ready()

	# link hitbox signal to our on_hit
	_hitbox.hit_hurtbox.connect(_on_hit)

func setup(data: DataProjectile) -> void:
	assert(
		data.travel_range is float,
		"ProjectileThrowable: `_travel_range` is missing."
	)

	super.setup(data)

	_set_travel_range(data.travel_range)
	_move_speed = data.move_speed
	_is_homing = data.is_homing

func activate() -> void:
	assert(
		_target_actor is CombatActor,
		"ProjectileThrowable: `_target_actor` is missing. Did you call `set_target_actor`
		before activate? "
	)

	_set_collision_disabled(false)
	_set_hitbox_disabled(false)
	_sprite.play()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	assert(_movement_component is PhysicsMovementComponent)
	#_movement_component.calc_movement(state)

func _physics_process(delta: float) -> void:
	_movement_component.pp(delta)

func _on_hit(hurtbox: HurtboxComponent) -> void:
	if !Utility.target_is_valid(_valid_hit_option, _hitbox.originator, hurtbox.root, _target_actor):
		return

	# update track of num bodies can hit
	_num_bodies_hit += 1

	# inform of hit
	hit_valid_target.emit(hurtbox)

	# spawn on hit effects
	_on_hit_effect_spawner.spawn_scene(global_position)

	# if we've reached max hits, prevent further hits and self terminate
	if _num_bodies_hit >= _max_bodies_can_hit:
		_set_hitbox_disabled(true)
		_set_collision_disabled(true)
		_terminate()
		_death_trigger.activate()

## update the stamina value of the supply container and the associated max range
func _set_travel_range(travel_range_: float) -> void:
	@warning_ignore("narrowing_conversion")  # happy with reduced precision
	_supply_container.get_supply(Constants.SUPPLY_TYPE.stamina).set_value(travel_range_)
	@warning_ignore("narrowing_conversion")  # happy with reduced precision
	_supply_container.get_supply(Constants.SUPPLY_TYPE.stamina).max_value = travel_range_

func set_target_actor(actor: CombatActor) -> void:
	super.set_target_actor(actor)
	_movement_component.set_target_actor(actor, _is_homing)


#endregion
