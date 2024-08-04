@icon("res://assets/node_icons/actor.png")
## entity that can move and fight in combat
class_name CombatActor
extends RigidBody2D


signal target_changed(actor: CombatActor)  ## changed target to new combat_actor
signal died  ## actor has died


@onready var _health: ResourceComponent = %Health
@onready var _on_hit_flash: FlashComponent = %OnHitFlash
@onready var reusable_spawner: SpawnerComponent = %ReusableSpawner  ## component for spawning runtime-defined Nodes on the actor
@onready var allegiance: Allegiance = %Allegiance


@export var target: CombatActor:  ## TODO: remove once proper targeting is in
	set(value):
		target = value
		target_changed.emit(target)
@export_category("Physics")
@export var _linear_damp: float = 5
@export var _mass: float = 100


func _ready() -> void:
	linear_damp = _linear_damp
	mass = _mass
	update_collisions()

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

## updates all collisions to reflect current target, team etc.
func update_collisions() -> void:
	Utility.update_body_collisions(self, allegiance.team, Constants.TARGET_OPTION.other, target)
