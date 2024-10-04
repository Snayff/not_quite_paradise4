## an active skill used in combat
##
## icon and effect chain are dyanmically loaded based on name. both must be in
## [PATH_COMBAT_ACTIVES].
@icon("res://combat/actives/combat_active.png")
class_name CombatActive
extends Node2D


#region SIGNALS
signal now_ready
signal new_target(target: Actor)
signal was_cast
#endregion


#region ON READY
@onready var _cooldown_timer: Timer = %CooldownTimer
@onready var _scene_spawner: SpawnerComponent = %SceneSpawner
@onready var _target_finder: TargetFinder = %TargetFinder
## handler for orbitals. Must have to be able to use `orbital` delivery method.
@onready var _orbiter: ProjectileOrbiterComponent = %ProjectileOrbiter

#endregion


#region EXPORTS
@export_group("Details")
## used to load data from library
@export var combat_active_name: String = ""
## time between casts. updates cooldown_timer on update. loaded from library.
var _cooldown_duration: float = 0:
	set(v):
		_cooldown_duration = v
		_cooldown_timer.wait_time = v
@export_group("Debug")
@export var _is_debug: bool = true  ## whether to show debug stuff
#endregion


#region VARS
var target_actor: Actor

# set by parent container
## who owns this active
var _caster: Actor
## creator's allegiance component
var _allegiance: Allegiance
##  projectile spawn location. Must have to be able to use `projectile` delivery method.
var _cast_position: Marker2D

# cast state
## if is off cooldown. set by cooldown timer timeout
var is_ready: bool = false:
	set(_value):
		is_ready = _value
		if is_ready:
			now_ready.emit()
var can_cast: bool:
	set(_value):
		push_error("CombatActive: Can't set `can_cast` directly.")
	get:
		if is_ready and target_actor is Actor:
			return true
		return false
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
## whether this active is selected by the parent container
var is_selected: bool = false

# flags
## if _ready() has finished
var _has_run_ready: bool = false

# data from library - combat active
## the icon used to identify the active
var icon: CompressedTexture2D
## how the combat active is cast
var _cast_type: Constants.CAST_TYPE = Constants.CAST_TYPE.manual
## what supply to pay the cast cost from
var cast_supply: Constants.SUPPLY_TYPE = Constants.SUPPLY_TYPE.stamina
## how much supply the cast costs
var cast_cost: int = 0
var valid_target_option: Constants.TARGET_OPTION  ## who the active can target
var _valid_effect_option: Constants.TARGET_OPTION  ## who the active's effects can affect
var _projectile_name: String = ""
var _effect_chain: ABCEffectChain
# data from library - projectile
var _delivery_method: Constants.EFFECT_DELIVERY_METHOD  ## how the active's effects are delivered
# FIXME: this isnt helpful for designing orbitals, e.g. how many rotations is it?!
## how far the can reach. when set, updates target finder.
var _max_range: float:
	set(value):
		_max_range = value
		if _target_finder is TargetFinder:
			_target_finder.set_max_range(_max_range)
#endregion


#region FUNCS

##########################
####### LIFECYCLE #######
########################

func _ready() -> void:
	# check for mandatory properties set in editor
	assert(_scene_spawner is SpawnerComponent, "CombatActive: Misssing `_scene_spawner`.")
	assert(_target_finder is TargetFinder, "CombatActive: Missing `_target_finder`.")

	# config cooldown timer
	_cooldown_timer.one_shot = true
	_cooldown_timer.timeout.connect(func(): is_ready = true)

	_has_run_ready = true

## run setup process. Also sets up all direct children.
##
## N.B. not recursive, so children are responsible for calling setup() on their own children
func setup(
	combat_active_name_: String,
	caster: Actor,
	allegiance: Allegiance,
	cast_position: Marker2D
	) -> void:
	combat_active_name = combat_active_name_

	if not _has_run_ready:
		push_error("CombatActive: setup() called before _ready. ")

	assert(caster is Actor, "CombatActive: Missing `caster`.")
	assert(allegiance is Allegiance, "CombatActive: Missing `allegiance`.")
	assert(cast_position is Marker2D, "CombatActive: Missing `cast_position`.")

	_load_data()

	# check effect chain loaded properly
	assert(_effect_chain is ABCEffectChain, "CombatActive: Missing `_effect_chain`.")

	# config target finder - # ensure we're in sync with range finders new target
	_target_finder.new_target.connect(set_target_actor)

	_caster = caster
	_allegiance = allegiance
	_cast_position = cast_position

	_effect_chain.setup(_caster, _allegiance, _valid_effect_option)

	_target_finder.setup(_caster, _max_range, valid_target_option, _allegiance)


## load data from the library and instantiate required children, e.g. [ABCEffectChain]
func _load_data() -> void:

	var dict_data: Dictionary = Library.get_combat_active_data(combat_active_name)

	# dynamically load icon and effect chain based on name
	icon = load(
		Constants.PATH_COMBAT_ACTIVES.path_join(
			str(combat_active_name, ".png")
		)
	)
	var effect_chain_script: Script = load(
		Constants.PATH_COMBAT_ACTIVES.path_join(
			str("effect_chain_", combat_active_name, ".gd")
		)
	)
	_effect_chain = effect_chain_script.new()
	add_child(_effect_chain)

	# assign values from data
	_cast_type = dict_data["cast_type"]
	cast_supply = dict_data["cast_supply"]
	cast_cost = dict_data["cast_cost"]
	valid_target_option = dict_data["valid_target_option"]
	_valid_effect_option = dict_data["valid_effect_option"]
	_projectile_name = dict_data["projectile_name"]
	_cooldown_timer.start(_cooldown_duration)
	_cooldown_duration = dict_data["cooldown_duration"]

	# config orbiter
	var max_projectiles: int = 0
	var orbit_radius: float = 0.0
	var orbit_rotation_speed: float = 0.0

	if (
		dict_data.has("max_projectiles") and \
		dict_data.has("orbit_radius") and \
		dict_data.has("orbit_rotation_speed")
	):
		max_projectiles = dict_data["max_projectiles"]
		orbit_radius = dict_data["orbit_radius"]
		orbit_rotation_speed = dict_data["orbit_rotation_speed"]

	_orbiter.setup(
		max_projectiles,
		orbit_radius,
		orbit_rotation_speed,
	)

	# internalise some projectile data, for easier use later
	_delivery_method = Library.get_projectile_data(_projectile_name)["effect_delivery_method"]
	_max_range = Library.get_projectile_range(_projectile_name)

func _process(_delta: float) -> void:
	queue_redraw()

	# handle auto casting
	if _cast_type == Constants.CAST_TYPE.auto:
		if can_cast:
			cast()

func _draw() -> void:
	## draw circle, or remove circle by redrawing without one
	if _is_debug and is_selected:
		if target_actor is Actor:
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
	if not target_actor is Actor:
		push_error("CombatActive: No target given to cast.")
		return

	match _delivery_method:
		Constants.EFFECT_DELIVERY_METHOD.throwable:
			_cast_throwable()

		Constants.EFFECT_DELIVERY_METHOD.orbital:
			_cast_orbital()

		Constants.EFFECT_DELIVERY_METHOD.area_of_effect:
			_cast_area_of_effect()

		Constants.EFFECT_DELIVERY_METHOD.aura:
			_cast_aura()

		_:
			push_error("CombatActive: `_delivery_method` (", _delivery_method, ") not defined.")

	was_cast.emit()

## set the target actor. can accept null.
func set_target_actor(actor: Actor) -> void:
	if actor is Actor:
		target_actor = actor
		if not target_actor.is_connected("died", set_target_actor):
			# remove the deceased from the signal and replace with null, to clear the target
			target_actor.died.connect(set_target_actor.unbind(1).bind(null))
		new_target.emit(actor)
	else:
		if _cooldown_timer.is_connected("timeout", cast):
			# if no target then keep cooldown going but dont connect to the cast
			_cooldown_timer.timeout.disconnect(cast)

## sets allegiance and updates child target finder's targeting info
##  (as this is contingent on allegiance).
func set_allegiance(allegiance: Allegiance) -> void:
	_allegiance = allegiance
	# FIXME: travel range and target option are set in library, need to get from there
	_target_finder.set_targeting_info(_max_range, valid_target_option, _allegiance)

## get how far the active can reach
func get_range() -> float:
	return _max_range

##########################
####### PRIVATE #########
########################

## start cooldown timer and update is_ready to false
func _restart_cooldown() -> void:
	_cooldown_timer.start()
	is_ready = false

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

		# FIXME: projectile appears at (0,0) and then jumps to position
		#		even moving this into orbiter, and even deferring, doesnt fix.
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
	var target_: Actor
	# FIXME: this is defined in library, need to get from there.
	if valid_target_option == Constants.TARGET_OPTION.self_:
		target_ = _caster
	else:
		target_ = target_actor

	var projectile: ProjectileAura = _create_projectile(
			_cast_position.global_position,
			_effect_chain.on_hit_multiple
		)
	projectile.set_target_actor(target_)

	_restart_cooldown()


#endregion
