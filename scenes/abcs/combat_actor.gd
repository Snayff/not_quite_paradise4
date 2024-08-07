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
@onready var _damage_numbers: PopUpNumbers = %DamageNumbers
@onready var _death_trigger: DeathTrigger = $DeathTrigger
@onready var _movement_component: MovementComponent = $MovementComponent


@export var target: CombatActor:  ## TODO: remove once proper targeting is in
	set(value):
		target = value
		target_changed.emit(target)
@export_category("Physics")
@export var _linear_damp: float = 5
@export var _mass: float = 100
@export var _is_player: bool = false  ## if the actor is player controlled


var force: Vector2 = Vector2.ZERO  # TODO: as it is passed up it shoudl be asignal


func _ready() -> void:
	linear_damp = _linear_damp
	mass = _mass
	lock_rotation = true

	update_collisions()


	# UPDATE CHILDREN
	if _health is ResourceComponent:
		_health.value_decreased.connect(_on_hit_flash.activate.unbind(1))  # activate flash on hit
		_health.emptied.connect(func(): died.emit())  # inform of death when empty

	if _movement_component is MovementComponent:
		_movement_component.is_attached_to_player = _is_player

	# CONNECT ALL SIGNALS
	# connect target_changed to all CombatActive children
	for child in get_children():
		if child is CombatActive:
			if not target_changed.is_connected(child.set_target_actor):
				target_changed.connect(child.set_target_actor)
	target_changed.emit(target)
	_health.value_decreased.connect(_damage_numbers.display_number)
	_death_trigger.died.connect(func(): died.emit())

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# stop sprite spinning
	rotation_degrees = 0  #FIXME: doesnt seem to work
	angular_velocity = 0
	global_rotation_degrees = 0

	if force != Vector2.ZERO:
		apply_central_impulse(force)

## updates all collisions to reflect current target, team etc.
func update_collisions() -> void:
	Utility.update_body_collisions(self, allegiance.team, Constants.TARGET_OPTION.other, target)
