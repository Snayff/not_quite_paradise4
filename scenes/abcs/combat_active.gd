## an active skill used in combat
@icon("res://assets/node_icons/combat_active.png")
class_name CombatActive
extends Node2D


#region SIGNALS

#endregion


#region ON READY
@onready var _cooldown_timer: Timer = %CooldownTimer
@onready var _projectile_spawner: SpawnerComponent = %ProjectileSpawner
@onready var _effect_chain: EffectChain = $EffectChain
#endregion


#region EXPORTS
@export_category("Component Links")
@export var _creator: CombatActor  ## who created this active
@export var _allegiance: Allegiance  ## creator's allegiance component
@export var _projectile_position: Marker2D  ##  projectile spawn location. Must have to be able to use `projectile` delivery method.
@export var _orbiter: ProjectileOrbiterComponent  ## handler for orbitals. Must have to be able to use `orbital` delivery method.

@export_category("Targeting")
@export var _valid_targets: Constants.TARGET_OPTION  ## who the active can affect

@export_category("Travel")
@export var _delivery_method: Constants.EFFECT_DELIVERY_METHOD  ## how the active's effects are delivered
@export var _travel_range: int

@export_category("Misc")
@export var is_active: bool = true  ## whether the CombatActive is functioning or not
#endregion


#region VARS
var target_actor: CombatActor
var target_position: Vector2  ## NOTE: not used

#endregion


#region FUNCS
func _ready() -> void:
	# check for mandatory properties set in editor
	assert(_creator is CombatActor, "Misssing `creator`.")
	assert(_allegiance is Allegiance, "Misssing `allegiance`.")
	assert(_projectile_spawner is SpawnerComponent, "Misssing `_projectile_spawner`.")
	assert(_effect_chain is EffectChain, "Missing `_effect_chain`.")

	_creator.target_changed.connect(set_target_actor)

	# config cooldown timer
	_cooldown_timer.start()

	# config effect chain
	_effect_chain.set_caster(_creator)


func cast()-> void:  # NOTE: should this be in an activation node?
	if not target_actor is CombatActor and not target_position is Vector2:
		push_error("CombatActive: No target given to cast.")
		return

	if not is_active:  # FIXME: this approach means the CombatActive will just keep looping the cooldown, rather than staying ready
		return

	if _delivery_method == Constants.EFFECT_DELIVERY_METHOD.projectile:
		if _projectile_position is Marker2D:
			_create_projectile()
		else:
			push_error("CombatActive: `_projectile_position` not defined.")

	elif _delivery_method == Constants.EFFECT_DELIVERY_METHOD.orbital:
		if _orbiter is ProjectileOrbiterComponent:
			var projectile = _create_orbital()
			projectile.died.connect(_orbiter.remove_projectile.bind(projectile))
			_orbiter.add_projectile(projectile)

		else:
			push_error("CombatActive: `_projectile_position` not defined.")
	else:
		push_error("CombatActive: `_delivery_method` (", _delivery_method, ") not defined.")

func _create_projectile() -> VisualProjectile:
	var projectile: VisualProjectile = _projectile_spawner.spawn_scene(_projectile_position.global_position)
	projectile.set_travel_range(_travel_range)
	projectile.set_target(target_actor, target_position)  # give both, blank one will be ignored
	projectile.set_interaction_info(_allegiance.team, _valid_targets)
	projectile.hit_valid_target.connect(_effect_chain.on_hit)
	projectile.update_collisions()

	return projectile

func _create_orbital()  -> VisualProjectile:
	var projectile: VisualProjectile = _projectile_spawner.spawn_scene(_creator.global_position, _orbiter)
	projectile.set_travel_range(_travel_range)
	#projectile.set_target(target_actor, target_position)  # give both, blank one will be ignored
	projectile.set_interaction_info(_allegiance.team, _valid_targets)
	projectile.hit_valid_target.connect(_effect_chain.on_hit)
	projectile.update_collisions()

	return projectile


func set_target_actor(actor: CombatActor) -> void:
	if actor is CombatActor:
		target_actor = actor
		_cooldown_timer.timeout.connect(cast)
		target_actor.died.connect(set_target_actor.bind(null))
	else:
		# if no target then keep cooldown going but dont connect to the cast
		_cooldown_timer.timeout.disconnect(cast)
#endregion
