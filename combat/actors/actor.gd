## entity that can move and fight in combat
@icon("res://combat/actors/actor.png")
class_name Actor
extends RigidBody2D

#region SIGNALS
signal new_target(actor: Actor)  ## changed target to new actor
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
@onready var physics_movement: PhysicsMovementComponent = %PhysicsMovement
@onready var _supply_container: SupplyContainer = %SupplyContainer
@onready var _centre_pivot: Marker2D = %CentrePivot
@onready var _tags: TagsComponent = %Tags
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
#endregion


#region EXPORTS
@export_group("Details")
@export var _is_player: bool = false  ## if the actor is player controlled
@export_group("Physics")
#@export var _linear_damp: float = 5  ## set here, rather than built-in prop, due to editor issue
#@export var _mass: float = 100  ## set here, rather than built-in prop, due to editor issue
#endregion


#region VARS
var _num_ready_actives: int = 0
var _global_cast_cd_counter: float = 0  ## counter to track time since last cast. # TODO: this needs implementing for player
var _target: Actor:
	set(value):
		_target = value
		new_target.emit(_target)
var main_sm: LimboHSM
#endregion


#region FUNCS
func _ready() -> void:
	# FIXME: placeholder to get data. same for below uses of `data`.
	var data = Library.get_data("actor", "wolf_rider")

	# NOTE: for some reason these arent being applied via the editor, but applying via code works
	linear_damp = Constants.LINEAR_DAMP
	mass = data["mass"]
	lock_rotation = true

	update_collisions()

	_death_trigger.died.connect(func(): died.emit())

	_sprite.sprite_frames = Utility.get_sprite_frame("actors", data["sprite_frames"])

	if _supply_container is SupplyContainer:
		_supply_container.create_supplies(data["supplies"])

		# setup triggers and process for death on health empty
		var health = _supply_container.get_supply(Constants.SUPPLY_TYPE.health)
		health.emptied.connect(func(): died.emit())  # inform of death when empty

		# and hit effects
		health.value_decreased.connect(_on_hit_flash.activate.unbind(1))  # activate flash on hit
		health.value_decreased.connect(_damage_numbers.display_number)

		# setup triggers and process for exhaustion on stamina empty
		var stamina = _supply_container.get_supply(Constants.SUPPLY_TYPE.stamina)
		stamina.emptied.connect(_apply_exhaustion)

	if physics_movement is PhysicsMovementComponent:
		physics_movement.is_attached_to_player = _is_player

		var ms = data["stats"][Constants.STAT_TYPE.move_speed]
		physics_movement.setup(ms, data["acceleration"], data["deceleration"])
		new_target.connect(physics_movement.set_target_actor.bind(false))

	if combat_active_container is CombatActiveContainer:
		combat_active_container.has_ready_active.connect(func(): _num_ready_actives += 1)  # support knowing when to auto cast
		combat_active_container.new_active_selected.connect(func(active): _target = active.target_actor) # update target to match that of selected active
		combat_active_container.new_target.connect(func(target): _target = target)

		if _is_player:
			var actives: Array[String] = []
			actives.assign(data["actives"])
			combat_active_container.create_actives(actives)

	if _tags is TagsComponent:
		var tags: Array[Constants.COMBAT_TAG] = []
		tags.assign(data["tags"])
		_tags.add_multiple_tags(tags)

	if stats_container is StatsContainer:
		stats_container.create_stats(data["stats"])

	_init_state_machine()

func _init_state_machine() -> void:
	main_sm = LimboHSM.new()
	add_child(main_sm)

	# create states
	var idle_state = LimboState.new() \
		.named("idle") \
		.call_on_enter(idle_start) \
		.call_on_update(idle_update)
	var walk_state = LimboState.new() \
		.named("walk") \
		.call_on_enter(walk_start) \
		.call_on_update(walk_update)
	var attack_state = LimboState.new() \
		.named("attack") \
		.call_on_enter(attack_start) \
		.call_on_update(attack_update)

	# add states to state machine
	main_sm.add_child(idle_state)
	main_sm.add_child(walk_state)
	main_sm.add_child(attack_state)

	main_sm.initial_state = idle_state

	main_sm.add_transition(idle_state, walk_state, &"to_walk")
	main_sm.add_transition(main_sm.ANYSTATE, idle_state, &"to_idle")
	main_sm.add_transition(main_sm.ANYSTATE, attack_state, &"to_attack")

	# init and activate state machine
	main_sm.initialize(self)
	main_sm.set_active(true)

var announced: bool = false

func idle_start() -> void:
	print("entered idle start")
	_sprite.play("idle")

func idle_update(delta: float) -> void:
	if announced == false:
		print("entered idle update.")
		announced = true

	if not linear_velocity.is_zero_approx():
		main_sm.dispatch(&"to_walk")
		announced = false

func walk_start() -> void:
	print("entered walk start")
	_sprite.play("walk")

func walk_update(delta: float) -> void:
	if announced == false:
		print("entered walk update")
		announced = true

	if linear_velocity.is_zero_approx():
		main_sm.dispatch(&"to_idle")
		announced = false
	else:
		_flip_sprite()

func attack_start() -> void:
	print("entered attack start")

func attack_update(delta: float) -> void:
	if announced == false:
		print("entered attack update")
		announced = true

func _flip_sprite() -> void:
	if linear_velocity.x > 0:
		_sprite.flip_h = false
	elif linear_velocity.x < 0:
		_sprite.flip_h = true

# FIXME: remove
#func move(direction: Vector2) -> void:
	#physics_movement.set_target_destination(direction)
#
func _physics_process(delta: float) -> void:
	if not _is_player:
		physics_movement.execute_physics(delta)

########### END AI ################

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
	# player uses a different approach to physics, for now
	if physics_movement is PhysicsMovementComponent and _is_player:
		physics_movement.apply_input_velocity(state)

## updates all collisions to reflect current _target, team etc.
func update_collisions() -> void:
	Utility.update_body_collisions(self, allegiance.team, Constants.TARGET_OPTION.other, _target)

## add the [BoonBaneExhaustion] [ABCBoonBane]. assumed to trigger after stamina is emptied.
func _apply_exhaustion() -> void:
	boons_banes.add_boon_bane(Constants.BOON_BANE_TYPE.exhaustion, self)

#endregion
