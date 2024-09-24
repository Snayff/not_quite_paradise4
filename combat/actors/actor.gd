## entity that can move and fight in combat
@icon("res://combat/actors/actor.png")
class_name Actor
extends RigidBody2D

#region SIGNALS
signal new_target(actor: Actor)  ## changed target to new combat_actor
signal died  ## actor has died
#endregion


#region ON READY
#FIXME: can we get rid of some of these? shouldnt we only need them for things we use in this script, rather than as an interface for other nodes, who
#  could use get_node()?
@onready var _on_hit_flash: VisualEffectFlash = %OnHitFlash
@onready var reusable_spawner: SpawnerComponent = %ReusableSpawner  ## component for spawning runtime-defined Nodes on the actor
@onready var allegiance: Allegiance = %Allegiance
@onready var combat_active_container: CombatActiveContainer = %CombatActiveContainer
@onready var stats_container: StatsContainer = %StatsContainer
@onready var boons_banes: BoonBaneContainer = %BoonsBanesContainer
@onready var _damage_numbers: PopUpNumbers = %DamageNumbers
@onready var _death_trigger: DeathTrigger = %DeathTrigger
@onready var _physics_movement: PhysicsMovementComponent = %PhysicsMovement
@onready var _supply_container: SupplyContainer = %SupplyContainer
@onready var _centre_pivot: Marker2D = %CentrePivot

#endregion


#region EXPORTS
@export_group("Details")
@export var _is_player: bool = false  ## if the actor is player controlled
@export_group("Physics")
@export var _linear_damp: float = 5  ## set here, rather than built-in prop, due to editor issue
@export var _mass: float = 100  ## set here, rather than built-in prop, due to editor issue
#endregion


#region VARS
var _num_ready_actives: int = 0
var _global_cast_cd_counter: float = 0  ## counter to track time since last cast. # TODO: this needs implementing for player
var _target: Actor:
	set(value):
		_target = value
		new_target.emit(_target)
#endregion


#region FUNCS
func _ready() -> void:
	# NOTE: for some reason these arent being applied via the editor, but applying via code works
	linear_damp = _linear_damp
	mass = _mass
	lock_rotation = true

	update_collisions()

	if _supply_container is SupplyContainer:
		# setup triggers and process for death on health empty
		var health = _supply_container.get_supply(Constants.SUPPLY_TYPE.health)
		health.emptied.connect(func(): died.emit())  # inform of death when empty

		# and hit effects
		health.value_decreased.connect(_on_hit_flash.activate.unbind(1))  # activate flash on hit
		health.value_decreased.connect(_damage_numbers.display_number)

		# setup triggers and process for exhaustion on stamina empty
		var stamina = _supply_container.get_supply(Constants.SUPPLY_TYPE.stamina)
		stamina.emptied.connect(_apply_exhaustion)

	if _physics_movement is PhysicsMovementComponent:
		_physics_movement.is_attached_to_player = _is_player

	_death_trigger.died.connect(func(): died.emit())

	combat_active_container.has_ready_active.connect(func(): _num_ready_actives += 1)  # support knowing when to auto cast
	combat_active_container.new_active_selected.connect(func(active): _target = active.target_actor) # update target to match that of selected active
	combat_active_container.new_target.connect(func(target): _target = target)

func _process(delta: float) -> void:
	_global_cast_cd_counter -= delta

	_update_non_player_auto_casting()

	# rotate cast position towards current target
	if combat_active_container.selected_active is CombatActive:
		if combat_active_container.selected_active.target_actor is Actor:
			_centre_pivot.look_at(combat_active_container.selected_active.target_actor.global_position)

## handle auto casting for non-player combat actors
func _update_non_player_auto_casting() -> void:
	# NOTE: should this be in an AI node?
	if not _is_player:
		if _num_ready_actives > 0:
			if _global_cast_cd_counter <= 0:
				if combat_active_container.cast_random_ready_active():
					_num_ready_actives -= 1
					_global_cast_cd_counter = Constants.GLOBAL_CAST_DELAY

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _physics_movement is PhysicsMovementComponent:
		_physics_movement.calc_movement(state)

## updates all collisions to reflect current _target, team etc.
func update_collisions() -> void:
	Utility.update_body_collisions(self, allegiance.team, Constants.TARGET_OPTION.other, _target)

## add the [BoonBaneExhaustion] [ABCBoonBane]. assumed to trigger after stamina is emptied.
func _apply_exhaustion() -> void:
	boons_banes.add_boon_bane(Constants.BOON_BANE_TYPE.exhaustion, self)

#endregion
