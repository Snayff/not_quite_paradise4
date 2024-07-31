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
var target_actor: CombatActor:
	set(value):
		movement_component.target_actor = value
		target_actor = value
# config
var creator: CombatActor  ## who created the projectile
var travel_range: int
var valid_targets: Constants.TARGET_OPTION
var team: Constants.TEAM
var target_resource: ResourceComponent  ## the resource damaged when the attached Hurtbox is hit
var speed: float  = 0.5 ## must be >0
var effect_chain: EffectChain  ## effect chain to be called when hitting valid target


func _ready() -> void:
	hitbox.hit_hurtbox.connect(_on_hit)

	movement_component.speed = speed

	if is_disabled:
		disable()

	_update_hitbox_collision()

func _process(delta: float) -> void:
	if movement_component.distance_travelled >= travel_range:
		print_debug("Projectile hit max range before hitting anything. ")
		death_trigger.activate()

## trigger on hit effects, if target is valid
func _on_hit(hurtbox: HurtboxComponent) -> void:
	if target_is_valid(hurtbox):
		hurtbox.hurt.emit(self)
		on_hit_effect_spawner.spawn_scene(global_position)
		death_trigger.activate()
		hit_valid_target.emit(hurtbox)

## check target is of type expected in `valid_targets`.
## Only check against the items that identify self or not self, as the team element is handled by collision layer/mask.
func target_is_valid(hurtbox: HurtboxComponent) -> bool:
	if valid_targets == Constants.TARGET_OPTION.self_:
		if hitbox.originator == hurtbox.root:
			return true
		else:
			return false

	elif valid_targets == Constants.TARGET_OPTION.other:
		if hitbox.originator != hurtbox.root:
			return true
		else:
			return false

	elif valid_targets == Constants.TARGET_OPTION.target:
		if target_actor == hurtbox.root:
			return true
		else:
			return false

	## ignore other target checks as already filtered by collision layers
	return true

func _update_hitbox_collision() -> void:
	if hitbox is HitboxComponent and team is Constants.TEAM and valid_targets is Constants.TARGET_OPTION:
		if team == Constants.TEAM.team1:
			if valid_targets == Constants.TARGET_OPTION.self_ or valid_targets == Constants.TARGET_OPTION.ally:
				hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], true)
				hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], false)
			elif valid_targets == Constants.TARGET_OPTION.enemy:
				hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], false)
				hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], true)
			elif valid_targets == Constants.TARGET_OPTION.other or valid_targets == Constants.TARGET_OPTION.anyone:
				hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], true)
				hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], true)
		elif team == Constants.TEAM.team2:
			if valid_targets == Constants.TARGET_OPTION.self_ or  valid_targets == Constants.TARGET_OPTION.ally:
				hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], false)
				hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], true)
			elif valid_targets == Constants.TARGET_OPTION.enemy:
				hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], true)
				hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], false)
			elif valid_targets == Constants.TARGET_OPTION.other or valid_targets == Constants.TARGET_OPTION.anyone:
				hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], true)
				hitbox.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], true)
		else:
			push_error("PhysicalProjectile: Team not found.")
	else:
		push_warning("PhysicalProjectile: Not enough info to setup hitbox collisions. No masks set (so wont hit anything). ")

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
