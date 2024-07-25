@icon("res://assets/node_icons/projectile.png")
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
var travel_range: int


func _ready() -> void:
	# TODO: ensure hitbox filters for correct targets
	# Error: E 0:00:02:0114   hitbox.gd:22 @ _on_hurtbox_entered(): Error calling from signal 'hit_hurtbox' to callable: 'Node2D(spawner.gd)::spawn_scene': Cannot convert argument 1 from Object to Vector2.
  #<C++ Source>   core/object/object.cpp:1140 @ emit_signalp()
  #<Stack Trace>  hitbox.gd:22 @ _on_hurtbox_entered()

	hitbox_component.hit_hurtbox.connect(on_hit_effect_spawner.spawn_scene.bind(global_position))

	if is_disabled:
		disable()


func _process(delta: float) -> void:
	if movement_component.distance_travelled >= travel_range:
		death_trigger.activate()

## wrapper for setting movement component's target actor
func set_target_actor(actor: CombatActor) -> void:
	movement_component.target_actor = actor

## wrapper for setting movement component's target position
func set_target_position(position_: Vector2) -> void:
	movement_component.target_position = position_

func enable() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	visible = true
	is_disabled = false

func disable() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	is_disabled = true
