## entity that can move and fight in combat
@icon("res://combat/actors/actor.png")
class_name Actor
extends RigidBody2D

#region SIGNALS
## changed target to new actor
signal new_target(actor: Actor)
## actor has died
signal died
#endregion


#region ON READY
@onready var _on_hit_flash: VisualEffectFlash = %OnHitFlash
## component for spawning runtime-defined Nodes on the actor
@onready var reusable_spawner: SpawnerComponent = %ReusableSpawner
@onready var allegiance: Allegiance = %Allegiance
@onready var combat_active_container: CombatActiveContainer = %CombatActiveContainer
@onready var stats_container: StatsContainer = %StatsContainer
@onready var boons_banes: BoonBaneContainer = %BoonsBanesContainer
@onready var _damage_numbers: PopUpNumbers = %DamageNumbers
@onready var _death_trigger: DeathTrigger = %DeathTrigger
@onready var physics_movement: PhysicsMovementComponent = %PhysicsMovement
@onready var _supply_container: SupplyContainer = %SupplyContainer
@onready var _centre_pivot: Marker2D = %CentrePivot
@onready var _tags: TagsComponent = %Tags
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _state_machine: ActorStateMachine = %StateMachine
#endregion


#region EXPORTS
@export_group("Details")
## if the actor is player controlled
@export var _is_player: bool = false
@export_group("Physics")
#endregion


#region VARS
var _num_ready_actives: int = 0
# TODO: this needs implementing
## counter to track time since last cast.
var _global_cast_cd_counter: float = 0
var _target: Actor:
	set(value):
		_target = value
		new_target.emit(_target)

#endregion


#region FUNCS

##########################
####### LIFECYCLE #######
########################

func _ready() -> void:
	# NOTE: for some reason these arent being applied via the editor, but applying via code works
	linear_damp = Constants.LINEAR_DAMP
	lock_rotation = true

	# FIXME: placeholder to get data. same for below uses of `data`.
	var data_dict = Library.get_data("actor", "wolf_rider")
	# TODO: move to an actor spawner object and factory, as required
	var data = DataActor.new()
	var actives: Array[String] = []
	actives.assign(data_dict["actives"])
	var tags: Array[Constants.COMBAT_TAG] = []
	tags.assign(data_dict["tags"])
	data.define(
		# FIXME: currently ignored as set in scene. used when moved to actor spawner
		Constants.TEAM.team1,
		Utility.get_sprite_frame("actors", data_dict["sprite_frames"]),
		data_dict["size"],
		data_dict["mass"],
		data_dict["acceleration"],
		data_dict["deceleration"],
		actives,
		data_dict["supplies"],
		data_dict["stats"],
		tags
	)
	setup(data)

# TODO: take a spawn position to spawn at.
func setup(data: DataActor) -> void:
	# NOTE: for some reason these arent being applied via the editor, but applying via code works
	mass = data["mass"]

	_death_trigger.died.connect(func(): died.emit())

	_sprite.sprite_frames = data.sprite_frames

	if _supply_container is SupplyContainer:
		_setup_supply_container(data)

	if physics_movement is PhysicsMovementComponent:
		_setup_physics_movement(data)

	if combat_active_container is CombatActiveContainer:
		_setup_combat_active_container(data)

	if _tags is TagsComponent:
		_setup_tags_container(data)

	if stats_container is StatsContainer:
		_setup_stats_container(data)

	_state_machine.init_state_machine()
	update_collisions()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	# player uses a different approach to physics, for now
	if physics_movement is PhysicsMovementComponent and _is_player:
		physics_movement.apply_input_velocity(state)

func _physics_process(delta: float) -> void:
	if not _is_player:
		physics_movement.execute_physics(delta)

func _process(_delta: float) -> void:
	# rotate cast position towards current target
	if combat_active_container.selected_active is CombatActive:
		if combat_active_container.selected_active.target_actor is Actor:
			_centre_pivot.look_at(combat_active_container.selected_active.target_actor.global_position)

##########################
####### PUBLIC ##########
########################

## updates all collisions to reflect current _target, team etc.
func update_collisions() -> void:
	Utility.update_body_collisions(self, allegiance.team, Constants.TARGET_OPTION.other, _target)

##########################
####### PRIVATE #########
########################

## add the [BoonBaneExhaustion]. assumed to trigger after stamina is emptied.
func _apply_exhaustion() -> void:
	boons_banes.add_boon_bane(Constants.BOON_BANE_TYPE.exhaustion, self)

func _setup_supply_container(data: DataActor) -> void:
	# create the required supplies
	_supply_container.create_supplies(data["supplies"])

	# set up triggers and process for death on health empty
	var health = _supply_container.get_supply(Constants.SUPPLY_TYPE.health)
	# inform of death when empty
	health.emptied.connect(func(): died.emit())

	# and hit effects
	# activate flash on hit
	health.value_decreased.connect(_on_hit_flash.activate.unbind(1))
	# show damage numbers
	health.value_decreased.connect(_damage_numbers.display_number)

	# setup triggers and process for exhaustion on stamina empty
	var stamina = _supply_container.get_supply(Constants.SUPPLY_TYPE.stamina)
	stamina.emptied.connect(_apply_exhaustion)

func _setup_physics_movement(data: DataActor) -> void:
	physics_movement.is_attached_to_player = _is_player

	# set move speed
	var ms = data["stats"][Constants.STAT_TYPE.move_speed]
	physics_movement.setup(ms, data["acceleration"], data["deceleration"])

	# link to actor finding new target
	new_target.connect(physics_movement.set_target_actor.bind(false))

func _setup_combat_active_container(data: DataActor) -> void:
	# link to combat active signals
	# support knowing when to auto cast
	combat_active_container.active_became_ready.connect(func(): _num_ready_actives += 1)
	# update target to match that of selected active
	combat_active_container.new_active_selected.connect(func(active): _target = active.target_actor)
	combat_active_container.new_target.connect(func(target): _target = target)

	combat_active_container.create_actives(data.actives)

func _setup_tags_container(data: DataActor) -> void:
	_tags.add_multiple_tags(data.tags)

func _setup_stats_container(data: DataActor) -> void:
	stats_container.create_stats(data["stats"])


#endregion
