## an active skill used in combat
@icon("res://assets/node_icons/combat_active.png")
class_name CombatActive
extends Node2D


@onready var _cooldown_timer: Timer = %CooldownTimer
@onready var _projectile_spawner: SpawnerComponent = %ProjectileSpawner
@onready var _effect_chain: EffectChain = %EffectChain


@export_category("Component Links")
@export var _creator: CombatActor  ## who created this active
@export var _allegiance: Allegiance  ## creator's allegiance component
@export var _projectile_position: Marker2D  ## the actors projectile spawn location

@export_category("Targeting")
@export var _valid_targets: Constants.TARGET_OPTION  ## who the active can affect

@export_category("Travel")
@export_enum("target", "projectile") var _delivery_method: String  ## how the active's effects are delivered  # NOTE: not used.
@export var _travel_range: int


var target_actor: CombatActor
var target_position: Vector2  ## NOTE: not used


func _ready() -> void:
	# check for mandatory properties set in editor
	assert(_creator is CombatActor, "Misssing `creator`.")
	assert(_allegiance is Allegiance, "Misssing `allegiance`.")
	assert(_projectile_spawner is SpawnerComponent, "Misssing `_projectile_spawner`.")

	_creator.target_changed.connect(set_target_actor)

	# config cooldown timer
	_cooldown_timer.start()

	# config effect chain
	_effect_chain.set_caster(_creator)

func cast()-> void:  # NOTE: should this be in an activation node?
	if not target_actor is CombatActor and not target_position is Vector2:
		push_error("CombatActive: No target given to cast.")
		return

	var projectile: PhysicalProjectile = _projectile_spawner.spawn_scene(_projectile_position.global_position)
	projectile.enable()
	projectile.travel_range = _travel_range
	projectile.team = _allegiance.team
	projectile.valid_targets = _valid_targets
	projectile.target_actor = target_actor
	if target_actor is CombatActor:
		projectile.set_target_actor(target_actor)
	elif target_position is Vector2:
		projectile.set_target_position(target_position)
	projectile.hit_valid_target.connect(_effect_chain.on_hit)

func set_target_actor(actor: CombatActor) -> void:
	if actor is CombatActor:
		target_actor = actor
		_cooldown_timer.timeout.connect(cast)
		target_actor.died.connect(set_target_actor.bind(null))
	else:
		# if no target then keep cooldown going but dont connect to the cast
		_cooldown_timer.timeout.disconnect(cast)
