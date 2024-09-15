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
@export var _projectile_name: String = ""
@export_group("Debug")
@export var _is_debug: bool = true  ## whether to show debug stuff

# FIXME: this isnt helpful for designing orbitals, e.g. how many rotations is it?! also no good for range finding
# TODO: rename to range. hide if delivery_method is melee and set to 15.
var _travel_range: int:  ## how far the projectile can travel. when set, updates target finder.
	set(value):
		_travel_range = value
		if _target_finder is TargetFinder:
			_target_finder.set_max_range(_travel_range)

#endregion


#region VARS
var target_actor: CombatActor
var target_position: Vector2  ## NOTE: not yet used
var is_ready: bool = false:  ## if is off cooldown. set by cooldown timer timeout
	set(_value):
		is_ready = _value
		if is_ready:
			now_ready.emit()

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
var _delivery_method: Constants.EFFECT_DELIVERY_METHOD  ## how the active's effects are delivered
#endregion


#region FUNCS

##########################
####### LIFECYCLE ######
######################

func _ready() -> void:
	# check for mandatory properties set in editor
	assert(_scene_spawner is SpawnerComponent, "CombatActive: Misssing `_scene_spawner`.")
	assert(_effect_chain is EffectChain, "CombatActive: Missing `_effect_chain`.")
	assert(_target_finder is TargetFinder, "CombatActive: Missing `_target_finder`.")

	# config cooldown timer
	_cooldown_timer.start()
	_cooldown_timer.one_shot = true
	_cooldown_timer.timeout.connect(func(): is_ready = true )

	# internalise delivery method
	_delivery_method = Library.get_projectile_data(_projectile_name)["effect_delivery_method"]

	# FIXME: this is now set in library, per projectile, so how do we update target finder?
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
			# FIXME: circle wobbles when player moves
			# get the offset and mulitply by distance
			var draw_pos: Vector2 = global_position.direction_to(target_actor.global_position) * \
				global_position.distance_to(target_actor.global_position)
			draw_circle(draw_pos, 10, Color.ALICE_BLUE, false, 1)

##########################
####### PUBLIC ##########
########################

## casts the active
func cast()-> void:
	if not target_actor is CombatActor and not target_position is Vector2:
		push_error("CombatActive: No target given to cast.")
		return

	if _delivery_method == Constants.EFFECT_DELIVERY_METHOD.throwable:
		_cast_throwable()

	elif _delivery_method == Constants.EFFECT_DELIVERY_METHOD.orbital:
		_cast_orbital()

	elif _delivery_method == Constants.EFFECT_DELIVERY_METHOD.area_of_effect:
		_cast_area_of_effect()

	elif _delivery_method == Constants.EFFECT_DELIVERY_METHOD.aura:
		_cast_aura()

	else:
		push_error("CombatActive: `_delivery_method` (", _delivery_method, ") not defined.")




func _create_projectile(cast_position: Vector2, on_hit_callable: Callable) -> ABCProjectile:
	var projectile: ABCProjectile = Factory.create_projectile(
		_projectile_name,
		_allegiance.team,
		cast_position,
		on_hit_callable
	)
	return projectile

func _cast_throwable() -> void:
	if _cast_position is Marker2D:
		var projectile: ProjectileThrowable = _create_projectile(
			_cast_position.global_position,
			_effect_chain.on_hit
		)
		projectile.set_target_actor(target_actor)
		projectile.activate()
		_restart_cooldown()
	else:
		push_error("CombatActive: `_cast_position` not defined.")

func _cast_orbital() -> void:
	if _orbiter is ProjectileOrbiterComponent:
		if _orbiter.has_max_projectiles:
			return

		var projectile: ProjectileOrbital = _create_projectile(
			_cast_position.global_position,
			_effect_chain.on_hit
		)
		projectile.died.connect(_orbiter.remove_projectile.bind(projectile))
		_orbiter.add_projectile(projectile)
		projectile.activate()
		_restart_cooldown()

	else:
		push_error("CombatActive: `_orbiter` not defined.")

func _cast_area_of_effect() -> void:
	if _cast_position is Marker2D:
		var projectile: ProjectileAreaOfEffect = _create_projectile(
			_cast_position.global_position,
			_effect_chain.on_hit_multiple
		)
		var angle: float = _caster.get_angle_to(target_actor.global_position)
		projectile.rotation = angle
		_restart_cooldown()
	else:
		push_error("CombatActive: `_cast_position` not defined.")

func _cast_aura() -> void:
	# set target so that aura follows them around
	var target_: CombatActor
	# FIXME: this is defined in library, need to get from there.
	if _valid_target_option == Constants.TARGET_OPTION.self_:
		target_ = _caster
	else:
		target_ = target_actor

	var projectile: ProjectileAura = _create_projectile(
			_cast_position.global_position,
			_effect_chain.on_hit_multiple
		)
	projectile.set_target_actor(target_)

	_restart_cooldown()

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
	# FIXME: travel range and target option are set in library, need to get from there
	_target_finder.set_targeting_info(_travel_range, _valid_target_option, _allegiance)

func set_projectile_position(marker: Marker2D) -> void:
	_cast_position = marker

##########################
####### PRIVATE #########
########################

## start cooldown timer and update is_ready to false
func _restart_cooldown() -> void:
	_cooldown_timer.start()
	is_ready = false
#
#
### create a throwable projectile at the _cast_position
#func _create_throwable() -> ProjectileThrowable:
	## TODO: active needs to specify projectile name
	#var projectile: ProjectileThrowable = Factory.create_projectile(
		#"fireball",
		 #_allegiance.team,
		#_cast_position.global_position,
		#_effect_chain.on_hit
	#)
	#return projectile
#
#func _create_orbital() -> ProjectileOrbital:
	#if not _orbiter.has_max_projectiles:
		#var projectile: ProjectileOrbital = Factory.create_projectile(
		#"fire_orb",
		 #_allegiance.team,
		#_cast_position.global_position,
		#_effect_chain.on_hit
		#)
		#return projectile
#
	#else:
		#return null
#
### create a projectile at the _target_position
#func _create_melee() -> ProjectileAreaOfEffect:
	#return Factory.create_projectile(
		#"slash",
		#_allegiance.team,
		#_cast_position.global_position,
		#_effect_chain.on_hit_multiple
	#)
#
#func _create_aura() -> ProjectileAura:
	#var target_: CombatActor
	#if _valid_target_option == Constants.TARGET_OPTION.self_:
		#target_ = _caster
	#else:
		#target_ = target_actor
#
	#var projectile: ProjectileAura = Factory.create_projectile(
		#"icy_wind",
		#_allegiance.team,
		#target_.global_position,
		#_effect_chain.on_hit_multiple
	#)
	#return projectile

#endregion
