## a projectile with physics
@icon("res://assets/node_icons/projectile.png")
class_name PhysicalProjectile
extends RigidBody2D


signal hit_valid_target(hurtbox: HurtboxComponent)


@onready var on_hit_effect_spawner: SpawnerComponent = %OnHitEffectSpawner
@onready var hitbox: HitboxComponent = %HitboxComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var death_trigger: DeathTrigger = %DeathTrigger


var is_disabled: bool = false  ## whether the projectile is disabled and hidden, or not
var _target_actor: CombatActor
# config
var creator: CombatActor  ## who created the projectile
var travel_range: int
var valid_effect_chain_target: Constants.TARGET_OPTION  ## who the effect chain can apply to
var valid_collision_target: Constants.TARGET_OPTION  ## who the physics collides with
var team: Constants.TEAM
var target_resource: SupplyComponent  ## the resource damaged when the attached Hurtbox is hit
var force_magnitude: float = 50.0
var force_application: String = "initial"
var _force_applied = false
var effect_chain: EffectChain  ## effect chain to be called when hitting valid target
var force: Vector2 = Vector2.ZERO  # TODO: as it is passed up it shoudl be asignal


func _ready() -> void:
	hitbox.hit_hurtbox.connect(_on_hit)
	hit_valid_target.connect(death_trigger.activate.unbind(1))

	movement_component.force_magnitude = force_magnitude

	if is_disabled:
		disable()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if _target_actor == null:
		return

	if force_application == "initial" and _force_applied == false:
		apply_central_impulse(force)  #FIXME: somehow keeps pushing actors for ages
		_force_applied = true
	elif force_application == "constant":
		apply_central_force(force)  # FIXME: why does this start slow then get faster?

func _process(delta: float) -> void:
	if movement_component.distance_travelled >= travel_range:
		print_debug("Projectile hit max range before hitting anything. ")
		death_trigger.activate()

## trigger on hit effects, if target is valid
func _on_hit(hurtbox: HurtboxComponent) -> void:
	if effect_chain_target_is_valid(hurtbox):
		hurtbox.hurt.emit(self)
		on_hit_effect_spawner.spawn_scene(global_position)
		death_trigger.activate()
		hit_valid_target.emit(hurtbox)

## check target is of type expected in `valid_effect_chain_target`.
## Only check against the items that identify self or not self, as the team element is handled by collision layer/mask.
func effect_chain_target_is_valid(hurtbox: HurtboxComponent) -> bool:
	if valid_effect_chain_target == Constants.TARGET_OPTION.self_:
		if hitbox.originator == hurtbox.root:
			return true
		else:
			return false

	elif valid_effect_chain_target == Constants.TARGET_OPTION.other:
		if hitbox.originator != hurtbox.root:
			return true
		else:
			return false

	elif valid_effect_chain_target == Constants.TARGET_OPTION.target:
		if _target_actor == hurtbox.root:
			return true
		else:
			return false

	## ignore other target checks as already filtered by collision layers
	return true

func _update_body_collisions() -> void:
		# check we have necessary info
	if team is Constants.TEAM and valid_collision_target is Constants.TARGET_OPTION:

		# only same team
		if valid_collision_target in [Constants.TARGET_OPTION.self_, Constants.TARGET_OPTION.ally]:
			set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_collision], team == Constants.TEAM.team1)
			set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_collision], team == Constants.TEAM.team2)

		# only other team
		elif valid_collision_target in [Constants.TARGET_OPTION.enemy]:
			set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_collision], team != Constants.TEAM.team1)
			set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_collision], team != Constants.TEAM.team2)

		# any team
		elif valid_collision_target in [Constants.TARGET_OPTION.anyone, Constants.TARGET_OPTION.other]:
			set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_collision], true)
			set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_collision], true)

		# only team of target
		elif valid_collision_target in [Constants.TARGET_OPTION.target]:
			if _target_actor is CombatActor:
				var target_allegiance: Allegiance = _target_actor.get_node_or_null("Allegiance")
				if target_allegiance is Allegiance:
					var target_team: Constants.TEAM = target_allegiance.team
					set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_collision], target_team == Constants.TEAM.team1)
					set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_collision], target_team == Constants.TEAM.team2)
					set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_collision], target_team == Constants.TEAM.team1)
					set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_collision], target_team == Constants.TEAM.team2)

		breakpoint

func _update_hitbox_collision() -> void:
	# check we have necessary info
	if hitbox is HitboxComponent and team is Constants.TEAM and valid_effect_chain_target is Constants.TARGET_OPTION:

		# only same team
		if valid_effect_chain_target in [Constants.TARGET_OPTION.self_, Constants.TARGET_OPTION.ally]:
			hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], team == Constants.TEAM.team1)
			hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], team == Constants.TEAM.team2)

		# only other team
		elif valid_effect_chain_target in [Constants.TARGET_OPTION.enemy]:
			hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], team != Constants.TEAM.team1)
			hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], team != Constants.TEAM.team2)

		# any team
		elif valid_effect_chain_target in [Constants.TARGET_OPTION.anyone, Constants.TARGET_OPTION.other]:
			hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], true)
			hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], true)

		# only team of target
		elif valid_effect_chain_target in [Constants.TARGET_OPTION.target]:
			if _target_actor is CombatActor:
				var target_allegiance: Allegiance = _target_actor.get_node_or_null("Allegiance")
				if target_allegiance is Allegiance:
					var target_team: Constants.TEAM = target_allegiance.team
					hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], target_team == Constants.TEAM.team1)
					hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], target_team == Constants.TEAM.team2)


## wrapper for setting movement component's target.
##
## Can give either an actor or a position. If both are given only actor is used.
## collisions may need updating after this.
func set_target(actor: CombatActor = null, position: Vector2 = Vector2.ZERO) -> void:
	if actor is CombatActor:
		_set_target_actor(actor)
	elif position is Vector2:
		_set_target_position(position)

func _set_target_actor(actor: CombatActor) -> void:
	_target_actor = actor
	movement_component.target_actor = actor


## wrapper for setting movement component's target position
func _set_target_position(position_: Vector2) -> void:
	movement_component.target_position = position_

## sets the values for the projectile so that it knows who to interact with.
##
## collisions may need updating after this.
func set_interaction_info(team_: Constants.TEAM, effect_chain_target: Constants.TARGET_OPTION, collision_target: Constants.TARGET_OPTION) -> void:
	team = team_
	valid_effect_chain_target = effect_chain_target
	valid_collision_target = collision_target

## updates all collisions to reflect current target, team etc.
func update_collisions() -> void:
	Utility.update_hitbox_hurtbox_collision(hitbox, team, valid_effect_chain_target, _target_actor)
	Utility.update_body_collisions(self, team, valid_collision_target, _target_actor)

func enable() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	visible = true
	is_disabled = false

func disable() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	is_disabled = true
