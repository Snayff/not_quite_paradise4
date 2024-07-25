## a projectile with physics
class_name PhysicalProjectile
extends Node2D

@onready var on_hit_effect_spawner: SpawnerComponent = %OnHitEffectSpawner
@onready var hitbox_component: HitboxComponent = %HitboxComponent
@onready var movement_component: MovementComponent = $MovementComponent


var creator: CombatActor  ## who created the projectile
var damage: int
var range: int
var _distance_travelled: float = 0


func _ready() -> void:
	# TODO: ensure hitbox filters for correct targets
	hitbox_component.hit_hurtbox.connect(on_hit_effect_spawner.spawn_scene.bind(global_position))

