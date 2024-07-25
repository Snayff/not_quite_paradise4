@icon("res://assets/node_icons/combat_active.png")
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
@export var travel_range: int

@export_category("Hit")
@export var damage: int
@export var aoe_radius: int

@export_category("Meta")
@export var cooldown: float  ## in seconds


var target_actor: CombatActor:
	set(value):
		value = value
var target_position: Vector2  ## NOTE: not used


func _ready() -> void:
	# check for mandatory properties set in editor
	assert(creator is CombatActor, "Misssing `creator`.")
	assert(allegiance is Allegiance, "Misssing `allegiance`.")
	assert(projectile_template is PhysicalProjectile, "Misssing `projectile_template`.")

	creator.target_changed.connect(func(target_actor_: CombatActor):
		target_actor = target_actor_
	)

	# config cooldown timer
	cooldown_timer.wait_time = cooldown
	cooldown_timer.timeout.connect(cast)

	# config projectile template
	projectile_template.is_disabled = true
	projectile_template.damage = damage
	projectile_template.travel_range = travel_range

	# TODO: add target info to projectile template

func cast()-> void:
	if not target_actor is CombatActor and not target_position is Vector2:
		push_error("No target given to cast.")
		return

	var projectile: PhysicalProjectile = projectile_spawner.spawn()
	projectile.enable()
	if target_actor is CombatActor:
		projectile.set_target_actor(target_actor)
	elif target_position is Vector2:
		projectile.set_target_position(target_position)
