## A projectile that moves, expires on reaching end of travel range,
## triggers effects on hit and on death
@icon("res://projectiles/projectile_throwable.png")
class_name ProjectileThrowable
extends ABCProjectile


#region SIGNALS
## emitted when resolved
signal hit_valid_target(hurtbox: HurtboxComponent)
#endregion


#region ON READY (for direct children only)
@onready var _on_hit_effect_spawner: SpawnerComponent = $OnHitEffectSpawner
@onready var _supply_container: SupplyContainer = $SupplyContainerComponent
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
var _max_range: float
## how fast we travel at max speed
var _max_speed: float
## whether we track targets movement and follow, or not
var _is_homing: bool

#endregion

# TODO: need to spend down stamina on movement

#region FUNCS

##########################
####### LIFECYCLE ######
######################

func _ready() -> void:
	super._ready()

	# link hitbox signal to our on_hit
	_hitbox.hit_hurtbox.connect(_on_hit)

## process setup. does NOT automatically trigger activate.
func setup(spawn_pos: Vector2, data: DataProjectile) -> void:
	assert(
		data.max_range is float,
		"ProjectileThrowable: `_max_range` is missing."
	)
	assert(
		data.max_speed is float,
		"ProjectileThrowable: `_max_speed` is missing."
	)
	assert(
		data.is_homing is bool,
		"ProjectileThrowable: `is_homing` is missing."
	)

	super.setup(spawn_pos, data)

	_set_max_range(data.max_range)
	_max_speed = data.max_speed
	_is_homing = data.is_homing
	lock_rotation = data.lock_rotation

	_movement_component.setup(data.max_speed, data.acceleration, data.deceleration)

func activate() -> void:
	assert(
		_target_actor is Actor,
		"ProjectileThrowable: `_target_actor` is missing. Did you call `set_target_actor` \
		before activate? "
	)

	_set_collision_disabled(false)
	_set_hitbox_disabled(false)

	_sprite.play()

func _physics_process(delta: float) -> void:
	_movement_component.execute_physics(delta)

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
	if _num_bodies_hit >= _max_bodies_can_hit and _max_bodies_can_hit != -1:
		_set_hitbox_disabled(true)
		_set_collision_disabled(true)
		_terminate()
		_death_trigger.activate()


######################
####### PUBLIC ######
####################

func set_target_actor(actor: Actor) -> void:
	super.set_target_actor(actor)
	_movement_component.set_target_actor(actor, _is_homing)

########################
####### PRIVATE #######
######################

## update the stamina value of the supply container and the associated max range
func _set_max_range(max_range_: float) -> void:
	#FIXME: supply has stamina, but thinks it is health?!?!
	var supply: SupplyComponent = _supply_container.get_supply(Constants.SUPPLY_TYPE.stamina)

	if supply is SupplyComponent:
		@warning_ignore("narrowing_conversion")  # happy with reduced precision
		supply.set_value(max_range_, max_range_)

	else:
		var supplies: Array[SupplyComponent] = _supply_container.get_all_supplies()
		var supply_names: Array[String] = []
		for s in supplies:
			supply_names.append(Utility.get_enum_name(Constants.SUPPLY_TYPE, s.type))
		push_error(
			"ProjectileThrowable: supply (",
			Utility.get_enum_name(Constants.SUPPLY_TYPE, Constants.SUPPLY_TYPE.stamina),
			") not found. SupplyContainer has ",
			supply_names,
			"."
		)


#endregion
