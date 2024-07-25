## a projectile with physics
class_name PhysicalProjectile
extends Node2D

@onready var on_hit_effect_spawner: SpawnerComponent = %OnHitEffectSpawner
@onready var hitbox_component: HitboxComponent = %HitboxComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var death_trigger: DeathTrigger = %DeathTrigger
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D


@export var is_disabled: bool = false  ## whether the projectile is disabled and hidden, or not


var creator: CombatActor  ## who created the projectile
var damage: int
var range: int


func _ready() -> void:
	# TODO: ensure hitbox filters for correct targets
	hitbox_component.hit_hurtbox.connect(on_hit_effect_spawner.spawn_scene.bind(global_position))

	if is_disabled:
		disable()


func _process(delta: float) -> void:
	if movement_component.distance_travelled >= range:
		death_trigger.activate()

## wrapper for setting movement component's target actor
func set_target_actor(actor: CombatActor) -> void:
	movement_component.target_actor = actor

## wrapper for setting movement component's target position
func set_target_position(position: Vector2) -> void:
	movement_component.target_position = position

func enable() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	visible = true
	is_disabled = false

func disable() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	is_disabled = true
