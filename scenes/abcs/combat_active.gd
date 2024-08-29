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
@onready var _projectile_spawner: SpawnerComponent = %ProjectileSpawner
@onready var _effect_chain: EffectChain = $EffectChain
@onready var _target_finder: TargetFinder = %TargetFinder
@onready var _orbiter: ProjectileOrbiterComponent = %ProjectileOrbiter  ## handler for orbitals. Must have to be able to use `orbital` delivery method.

#endregion


#region EXPORTS
# TODO: move these to a config node, so designing a combat active is abstracted and only available within scene
@export_group("Aesthetics")
@export var icon: CompressedTexture2D  ## the icon used to identify the active
@export_group("Casting")
@export var _cast_type: Constants.CAST_TYPE  ## how the active is cast
@export_group("Targeting")
@export var _valid_target_option: Constants.TARGET_OPTION  ## who the active can target
@export var _valid_effect_option: Constants.TARGET_OPTION  ## who the active's effects can affect
@export_group("Travel")
@export var _delivery_method: Constants.EFFECT_DELIVERY_METHOD  ## how the active's effects are delivered
#FIXME: this isnt helpful for designing orbitals, e.g. how many rotations is it?! also no good for range finding
@export var _travel_range: int:  ## how far the projectile can travel. when set, updates target finder.
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
var _is_debug: bool = true  ## whether to show debug stuff
# set by parent container
var _actor: CombatActor  ## who owns this active
var _allegiance: Allegiance  ## creator's allegiance component
var _projectile_position: Marker2D  ##  projectile spawn location. Must have to be able to use `projectile` delivery method.
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
#endregion


#region FUNCS
func _ready() -> void:
	# check for mandatory properties set in editor
	assert(_projectile_spawner is SpawnerComponent, "Misssing `_projectile_spawner`.")
	assert(_effect_chain is EffectChain, "Missing `_effect_chain`.")
	assert(_target_finder is TargetFinder, "Missing `_target_finder`.")

	# config cooldown timer
	_cooldown_timer.start()
	_cooldown_timer.one_shot = true
	_cooldown_timer.timeout.connect(func(): is_ready = true )

	# config effect chain
	_effect_chain.set_caster(_actor)

	# config target finder - need to set target info once allegiance is init'd
	_target_finder.set_root(_actor)
	_target_finder.new_target.connect(set_target_actor)  # ensure we're in sync with range finders new target

func _process(delta: float) -> void:
	queue_redraw()

	# handle auto casting
	if _cast_type == Constants.CAST_TYPE.auto:
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
		if _projectile_position is Marker2D:
			_create_projectile()
			_cooldown_timer.start()
			is_ready = false
		else:
			push_error("CombatActive: `_projectile_position` not defined.")

	elif _delivery_method == Constants.EFFECT_DELIVERY_METHOD.orbital:
		if _orbiter is ProjectileOrbiterComponent:
			var projectile = _create_orbital()
			if projectile != null:
				projectile.died.connect(_orbiter.remove_projectile.bind(projectile))
				_orbiter.add_projectile(projectile)
				_cooldown_timer.start()
				is_ready = false

		else:
			push_error("CombatActive: `_projectile_position` not defined.")
	else:
		push_error("CombatActive: `_delivery_method` (", _delivery_method, ") not defined.")

func _create_projectile() -> VisualProjectile:
	var projectile: VisualProjectile = _projectile_spawner.spawn_scene(_projectile_position.global_position)
	projectile.set_travel_range(_travel_range)
	projectile.set_target(target_actor, target_position)  # give both, blank one will be ignored
	projectile.set_interaction_info(_allegiance.team, _valid_effect_option)
	projectile.hit_valid_target.connect(_effect_chain.on_hit)
	projectile.update_collisions()

	return projectile

## creates an orbital projectile in the _orbiter component.
##
## returns null if could not create, e.g. if already at max orbitals
func _create_orbital()  -> VisualProjectile:
	if not _orbiter.has_max_projectiles:
		var projectile: VisualProjectile = _projectile_spawner.spawn_scene(_actor.global_position, _orbiter)
		projectile.set_travel_range(_travel_range)
		projectile.set_interaction_info(_allegiance.team, _valid_effect_option)
		projectile.hit_valid_target.connect(_effect_chain.on_hit)
		projectile.update_collisions()

		return projectile
	else:
		return null

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
	_projectile_position = marker

## sets owner and updates children with same.
func set_owning_actor(actor: CombatActor) -> void:
		_actor = actor
		_effect_chain.set_caster(actor)
		_target_finder.set_root(actor)
#endregion
