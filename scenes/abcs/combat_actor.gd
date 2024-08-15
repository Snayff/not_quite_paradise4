@icon("res://assets/node_icons/actor.png")
## entity that can move and fight in combat
class_name CombatActor
extends RigidBody2D

#region SIGNALS
signal target_changed(actor: CombatActor)  ## changed target to new combat_actor
signal died  ## actor has died
#endregion


#region ON READY
#FIXME: can we get rid of some of these? shouldnt we only need them for things we use in this script, rather than as an interface for other nodes, who
#  could use get_node()?
@onready var _health: SupplyComponent = %Health
@onready var _on_hit_flash: FlashComponent = %OnHitFlash
@onready var reusable_spawner: SpawnerComponent = %ReusableSpawner  ## component for spawning runtime-defined Nodes on the actor
@onready var allegiance: Allegiance = %Allegiance
@onready var _damage_numbers: PopUpNumbers = %DamageNumbers
@onready var _death_trigger: DeathTrigger = %DeathTrigger
@onready var _physics_movement: PhysicsMovementComponent = %PhysicsMovement
@onready var boons_banes: BoonsBanesContainerComponent = %BoonsBanesContainer
@onready var supply_container: SupplyContainerComponent = %SupplyContainer

#endregion


#region EXPORTS
@export_group("Details")
@export var _is_player: bool = false  ## if the actor is player controlled
@export_group("Targeting")
@export var target: CombatActor:  ## TODO: remove once proper targeting is in
	set(value):
		target = value
		target_changed.emit(target)
@export_group("Physics")
@export var _linear_damp: float = 5
@export var _mass: float = 100
#endregion


#region VARS

#endregion


#region FUNCS
func _ready() -> void:
	# NOTE: for some reason these arent being applied via the editor, but applying via code works
	linear_damp = _linear_damp
	mass = _mass
	lock_rotation = true

	update_collisions()

	# UPDATE CHILDREN
	if _health is SupplyComponent:
		_health.value_decreased.connect(_on_hit_flash.activate.unbind(1))  # activate flash on hit
		_health.emptied.connect(func(): died.emit())  # inform of death when empty

	if _physics_movement is PhysicsMovementComponent:
		_physics_movement.is_attached_to_player = _is_player

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
	if _physics_movement is PhysicsMovementComponent:
		_physics_movement.calc_movement(state)

## updates all collisions to reflect current target, team etc.
func update_collisions() -> void:
	Utility.update_body_collisions(self, allegiance.team, Constants.TARGET_OPTION.other, target)
#endregion
