@icon("res://assets/node_icons/actor.png")
## entity that can move and fight in combat
class_name CombatActor
extends RigidBody2D


signal target_changed(actor: CombatActor)  ## changed target to new combat_actor
signal died  ## actor has died


@onready var _health: ResourceComponent = %Health
@onready var _on_hit_flash: FlashComponent = %OnHitFlash
@onready var reusable_spawner: SpawnerComponent = %ReusableSpawner  ## component for spawning runtime-defined Nodes on the actor


@export var target: CombatActor:  ## TODO: remove once proper targeting is in
	set(value):
		target = value
		target_changed.emit(target)


func _ready() -> void:
	if _health is ResourceComponent:
		_health.value_decreased.connect(_on_hit_flash.activate)  # activate flash on hit
		_health.emptied.connect(func(): died.emit())  # inform of death when empty

	# connect target_changed to all CombatActive children
	for child in get_children():
		if child is CombatActive:
			if not target_changed.is_connected(child.set_target_actor):
				target_changed.connect(child.set_target_actor)

	target_changed.emit(target)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# stop sprite spinning
	#rotation_degrees = 0
	pass
	#linear_velocity = linear_velocity * 0.9

