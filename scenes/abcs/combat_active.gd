## an active skill used in combat
class_name CombatActive
extends Node2D

@onready var cooldown_timer: Timer = %CooldownTimer
@onready var projectile_spawner: SpawnerComponent = %ProjectileSpawner


@export_category("Component Links")
@export var creator: CombatActor  ## who created this active
@export var allegiance: Allegiance  ## creator's allegiance component
@export var projectile_template: PhysicalProjectile  ## the projectile to use as a template

@export_category("Targeting")
@export var valid_targets: Constants.TARGET  ## who the active can affect

@export_category("Travel")
@export_enum("target", "projectile") var delivery_method: String  ## how the active's effects are delivered
@export var range: int

@export_category("Hit")
@export var damage: int
@export var aoe_radius: int

@export_category("Meta")
@export var cooldown: float  ## in seconds


func _ready() -> void:
	# check for mandatory properties set in editor
	assert(creator is CombatActor, "Misssing `creator`.")
	assert(allegiance is Allegiance, "Misssing `allegiance`.")
	assert(projectile_template is PhysicalProjectile, "Misssing `projectile_template`.")

	# config cooldown timer
	cooldown_timer.wait_time = cooldown
	cooldown_timer.timeout.connect(cast)

	# config projectile template
	projectile_template.damage = damage
	projectile_template.range = range

	# TODO: add target info to projectile template

func cast(target_actor = null, target_position = null)-> void:
	if not target_actor is CombatActor and not target_position is Vector2:
		push_error("No target given to cast.")
		return

	var projectile: PhysicalProjectile = projectile_spawner.spawn()
	if target_actor is CombatActor:
		projectile.set_target_actor(target_actor)
	elif target_position is Vector2:
		projectile.set_target_position(target_position)
