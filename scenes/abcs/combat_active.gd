@icon("res://assets/node_icons/combat_active.png")
## an active skill used in combat
class_name CombatActive
extends Node2D

@onready var cooldown_timer: Timer = %CooldownTimer
@onready var projectile_spawner: SpawnerComponent = %ProjectileSpawner


@export_category("Component Links")
@export var creator: CombatActor  ## who created this active
@export var allegiance: Allegiance  ## creator's allegiance component
@export var projectile_position: Marker2D  ## the actors projectile spawn location

@export_category("Targeting")
@export var valid_targets: Constants.TARGET  ## who the active can affect

@export_category("Travel")
@export_enum("target", "projectile") var delivery_method: String  ## how the active's effects are delivered
@export var travel_range: int

@export_category("Hit")
@export var damage: int
@export var aoe_radius: int

@export_category("Meta")
@export var cooldown: float  ## in seconds


var target_actor: CombatActor
var target_position: Vector2  ## NOTE: not used


func _ready() -> void:
	# check for mandatory properties set in editor
	assert(creator is CombatActor, "Misssing `creator`.")
	assert(allegiance is Allegiance, "Misssing `allegiance`.")
	assert(projectile_spawner is SpawnerComponent, "Misssing `projectile_spawner`.")

	creator.target_changed.connect(_set_target_actor)

	# config cooldown timer
	cooldown_timer.wait_time = cooldown

func cast()-> void:
	if not target_actor is CombatActor and not target_position is Vector2:
		push_error("No target given to cast.")
		return

	var projectile: PhysicalProjectile = projectile_spawner.spawn(projectile_position.global_position)
	projectile.enable()
	projectile.damage = damage
	projectile.travel_range = travel_range
	projectile.team = allegiance.team
	projectile.valid_targets = valid_targets
	if target_actor is CombatActor:
		projectile.set_target_actor(target_actor)
	elif target_position is Vector2:
		projectile.set_target_position(target_position)

func _set_target_actor(actor: CombatActor) -> void:
	if actor is CombatActor:
		target_actor = actor
		cooldown_timer.timeout.connect(cast)
	else:
		# if no target then keep cooldown going but dont connect to the cast
		cooldown_timer.timeout.disconnect(cast)
