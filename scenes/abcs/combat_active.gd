## ABC for an active skill used in combat
@icon("res://assets/node_icons/combat_active.png")
class_name CombatActive
extends Node2D


#region SIGNALS
signal now_ready
signal new_target(target: CombatActor)
#endregion


#region ON READY
@onready var _cooldown_timer: Timer = %CooldownTimer
@onready var _scene_spawner: SpawnerComponent = %SceneSpawner
@onready var _effect_chain: EffectChain = $EffectChain
@onready var _target_finder: TargetFinder = %TargetFinder
@onready var _orbiter: ProjectileOrbiterComponent = %ProjectileOrbiter  ## handler for orbitals. Must have to be able to use `orbital` delivery method.

#endregion


#region EXPORTS
# TODO: move these to a config node, so designing a combat active is abstracted and only available within scene
@export_group("Aesthetics")
@export var icon: CompressedTexture2D  ## the icon used to identify the active
@export_group("Casting")
@export var cast_type: Constants.CAST_TYPE = Constants.CAST_TYPE.manual ## how the active is cast
@export var cast_supply: Constants.SUPPLY_TYPE = Constants.SUPPLY_TYPE.stamina  ## what supply to pay the cast cost from
@export var cast_cost: int = 0
@export_group("Targeting")
@export var _valid_target_option: Constants.TARGET_OPTION  ## who the active can target
@export var _valid_effect_option: Constants.TARGET_OPTION  ## who the active's effects can affect
@export_group("Delivery")
@export var _delivery_method: Constants.EFFECT_DELIVERY_METHOD  ## how the active's effects are delivered
@export var _delivery_radius: float = 1  ## how big the delivery method is, e.g. size of melee aoe
# FIXME: this isnt helpful for designing orbitals, e.g. how many rotations is it?! also no good for range finding
# TODO: rename to range. hide if delivery_method is melee and set to 15.
@export var _travel_range: int:  ## how far the projectile can travel. when set, updates target finder.
	set(value):
		_travel_range = value
		if _target_finder is TargetFinder:
			_target_finder.set_max_range(_travel_range)
@export_group("Aura")
@export var _aura_lifetime: float = -1  ## how long the aura should last. only applies if delivery method == aura.

#endregion


#region VARS
var target_actor: CombatActor
var target_position: Vector2  ## NOTE: not yet used
var is_ready: bool = false:  ## if is off cooldown. set by cooldown timer timeout
	set(_value):
		is_ready = _value
		if is_ready:
			now_ready.emit()
var _is_debug: bool = true  ## whether to show debug stuff
# set by parent container
var _caster: CombatActor  ## who owns this active
var _allegiance: Allegiance  ## creator's allegiance component
var _cast_position: Marker2D  ##  projectile spawn location. Must have to be able to use `projectile` delivery method.
var time_until_ready: float:
	set(value):
		push_error("CombatActive: Can't set `time_until_ready` directly.")
	get():
		return _cooldown_timer.time_left
var percent_ready: float:
	set(value):
		push_error("CombatActive: Can't set `percent_ready` directly.")
	get():
		return _cooldown_timer.time_left / _cooldown_timer.wait_time
var is_selected: bool = false  ## whether this active is selected by the parent container
var can_cast: bool:
	set(_value):
		push_error("CombatActive: Can't set `can_cast` directly.")
	get:
		if is_ready and target_actor is CombatActor:
			return true
		return false
var _has_run_ready: bool = false  ## if _ready() has finished
#endregion


#region FUNCS
func _ready() -> void:
	# check for mandatory properties set in editor
	assert(_scene_spawner is SpawnerComponent, "CombatActive: Misssing `_scene_spawner`.")
	assert(_effect_chain is EffectChain, "CombatActive: Missing `_effect_chain`.")
	assert(_target_finder is TargetFinder, "CombatActive: Missing `_target_finder`.")

	# config cooldown timer
	_cooldown_timer.start()
	_cooldown_timer.one_shot = true
	_cooldown_timer.timeout.connect(func(): is_ready = true )

	# config target finder
	_target_finder.new_target.connect(set_target_actor)  # ensure we're in sync with range finders new target

	_has_run_ready = true

## run setup process and repeat on all direct children.
##
## N.B. not recursive, so children are responsible for calling setup() on their own children
func setup(caster: CombatActor, allegiance: Allegiance, cast_position: Marker2D) -> void:
	if not _has_run_ready:
		push_error("CombatActive: setup() called before _ready. ")

	assert(caster is CombatActor, "CombatActive: Missing `caster`.")
	assert(allegiance is Allegiance, "CombatActive: Missing `allegiance`.")
	assert(cast_position is Marker2D, "CombatActive: Missing `cast_position`.")

	_caster = caster
	_allegiance = allegiance
	_cast_position = cast_position

	_effect_chain.setup(_caster, _allegiance, _valid_effect_option)

	_target_finder.setup(_caster, _travel_range, _valid_target_option, _allegiance)

func _process(_delta: float) -> void:
	queue_redraw()

	# handle auto casting
	if cast_type == Constants.CAST_TYPE.auto:
		if can_cast:
			cast()

func _draw() -> void:
	## draw circle, or remove circle by redrawing without one
	if _is_debug and is_selected:
		if target_actor is CombatActor:
			# get the offset and mulitply by distance
			# FIXME: circle wobbles when player moves
			var draw_pos: Vector2 =  global_position.direction_to(target_actor.global_position) * global_position.distance_to(target_actor.global_position)
			draw_circle(draw_pos, 10, Color.ALICE_BLUE, false, 1)

## casts the active
func cast()-> void:
	if not target_actor is CombatActor and not target_position is Vector2:
		push_error("CombatActive: No target given to cast.")
		return

	if _delivery_method == Constants.EFFECT_DELIVERY_METHOD.projectile:
		if _cast_position is Marker2D:
			# _create_projectile()
			var projectile: ProjectileThrowable = _create_projectile_new()
			projectile.set_target_actor(target_actor)
			projectile.activate()
			_restart_cooldown()
		else:
			push_error("CombatActive: `_cast_position` not defined.")

	elif _delivery_method == Constants.EFFECT_DELIVERY_METHOD.orbital:
		if _orbiter is ProjectileOrbiterComponent:
			var projectile = _create_orbital()
			if projectile != null:
				projectile.died.connect(_orbiter.remove_projectile.bind(projectile))
				_orbiter.add_projectile(projectile)
				_restart_cooldown()

		else:
			push_error("CombatActive: `_orbiter` not defined.")

	elif _delivery_method == Constants.EFFECT_DELIVERY_METHOD.melee:
		if _cast_position is Marker2D:
			_create_melee()
			_restart_cooldown()
		else:
			push_error("CombatActive: `_cast_position` not defined.")

	elif _delivery_method == Constants.EFFECT_DELIVERY_METHOD.aura:
		_create_aura()
		_restart_cooldown()

	else:
		push_error("CombatActive: `_delivery_method` (", _delivery_method, ") not defined.")

## create a projectile at the _cast_position
func _create_projectile() -> VisualProjectile:
	var projectile: VisualProjectile = _scene_spawner.spawn_scene(_cast_position.global_position)
	projectile.setup(_travel_range, _allegiance.team, _valid_effect_option, target_actor, target_position)
	projectile.hit_valid_target.connect(_effect_chain.on_hit)

	return projectile

func _create_projectile_new() -> ABCProjectile:
	var projectile: ABCProjectile = Factory.create_projectile("fireball", _allegiance.team)
	projectile.hit_valid_target.connect(_effect_chain.on_hit)
	projectile.global_position = _cast_position.global_position
	return projectile

## creates an orbital projectile in the _orbiter component.
##
## returns null if could not create, e.g. if already at max orbitals
func _create_orbital()  -> VisualProjectile:
	if not _orbiter.has_max_projectiles:
		var projectile: VisualProjectile = _scene_spawner.spawn_scene(_caster.global_position, _orbiter)
		projectile.setup(_travel_range, _allegiance.team, _valid_effect_option)
		projectile.hit_valid_target.connect(_effect_chain.on_hit)

		return projectile

	else:
		return null

## create an [AreaOfEffect] at the _target_position
func _create_melee() -> AreaOfEffect:
	var aoe: AreaOfEffect = _scene_spawner.spawn_scene(_cast_position.global_position)
	aoe.setup(aoe.global_position, _allegiance.team, _valid_effect_option, _delivery_radius)
	aoe.hit_valid_targets.connect(_effect_chain.on_hit_multiple)
	var angle = _caster.get_angle_to(target_actor.global_position)
	aoe.rotation = angle

	return aoe

## create an [Aura] at the either the caster's or target's position, based on [_valid_target_option], with the Aura targeting the same.
##
## if _valid_target_option == TARGET_OPTION.self then targets self, otherwise targets [target_actor]
func _create_aura() -> Aura:
	# NOTE: because we dont keep track of auras created we cant clear them on demand.
	var target_: CombatActor
	if _valid_target_option == Constants.TARGET_OPTION.self_:
		target_ = _caster
	else:
		target_ = target_actor

	var aura: Aura = _scene_spawner.spawn_scene(target_.global_position)
	aura.setup(aura.global_position, _allegiance.team, _valid_effect_option, _delivery_radius, _aura_lifetime)
	aura.hit_valid_targets.connect(_effect_chain.on_hit_multiple)
	aura.attach_to_target(target_)

	return aura

## set the target actor. can accept null.
func set_target_actor(actor: CombatActor) -> void:
	if actor is CombatActor:
		target_actor = actor
		if not target_actor.is_connected("died", set_target_actor):
			target_actor.died.connect(set_target_actor.bind(null))  # to clear target
		new_target.emit(actor)
	else:
		if _cooldown_timer.is_connected("timeout", cast):
			# if no target then keep cooldown going but dont connect to the cast
			_cooldown_timer.timeout.disconnect(cast)

## sets allegiance and updates child target finder's targeting info (as this is contingent on allegiance).
func set_allegiance(allegiance: Allegiance) -> void:
	_allegiance = allegiance
	_target_finder.set_targeting_info(_travel_range, _valid_target_option, _allegiance)

func set_projectile_position(marker: Marker2D) -> void:
	_cast_position = marker

## start cooldown timer and update is_ready to false
func _restart_cooldown() -> void:
	_cooldown_timer.start()
	is_ready = false

#endregion
