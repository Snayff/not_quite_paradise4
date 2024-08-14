## a projectile without any physical interaction with the world
##
## still have collisions etc., but doesnt naturally affect the physical world just by existing, a la RigidBody.
@icon("res://assets/node_icons/visual_projectile.png")
class_name VisualProjectile
extends AnimatedSprite2D


#region SIGNALS
signal hit_valid_target(hurtbox: HurtboxComponent)
signal died
#endregion


#region ON READY
@onready var on_hit_effect_spawner: SpawnerComponent = %OnHitEffectSpawner
@onready var hitbox: HitboxComponent = %HitboxComponent
@onready var movement_component: MovementComponent = %MovementComponent
@onready var death_trigger: DeathTrigger = %DeathTrigger
@onready var travel_range_resource: ResourceComponent = %TravelRange

#endregion


#region EXPORTS
#@export_group("Component Links")
#@export_group("Config")

#endregion


#region VARS
# internals
var _target_actor: CombatActor
var _target_position: Vector2
var creator: CombatActor  ## who created the projectile
var team: Constants.TEAM
# config - these are all set by the combat active
var valid_effect_chain_target: Constants.TARGET_OPTION  ## who the effect chain can apply to
var target_resource: ResourceComponent  ## the resource damaged when a valid Hurtbox is hit
var effect_chain: EffectChain  ## effect chain to be called when hitting valid target

#endregion


#region FUNCS
func _ready() -> void:
	hitbox.hit_hurtbox.connect(_on_hit)
	hit_valid_target.connect(death_trigger.activate.unbind(1))
	death_trigger.died.connect(func(): died.emit())

## trigger on hit effects, if target is valid
func _on_hit(hurtbox: HurtboxComponent) -> void:
	if Utility.target_is_valid(valid_effect_chain_target, hitbox.originator, hurtbox.root, _target_actor):
		hurtbox.hurt.emit(self)
		on_hit_effect_spawner.spawn_scene(global_position)
		death_trigger.activate()
		hit_valid_target.emit(hurtbox)

## wrapper for setting movement component's target.
##
## Can give either an actor or a position. If both are given only actor is used.
## collisions may need updating after this.
func set_target(actor: CombatActor = null, position_: Vector2 = Vector2.ZERO) -> void:
	if actor is CombatActor:
		_set_target_actor(actor)
	elif position_ is Vector2:
		_set_target_position(position_)

func _set_target_actor(actor: CombatActor) -> void:
	_target_actor = actor
	movement_component.target_actor = actor


## wrapper for setting movement component's target position
func _set_target_position(position_: Vector2) -> void:
	_target_position = position_
	movement_component.target_position = position_

## sets the values for the projectile so that it knows who to interact with.
##
## collisions may need updating after this.
func set_interaction_info(team_: Constants.TEAM, effect_chain_target: Constants.TARGET_OPTION) -> void:
	team = team_
	valid_effect_chain_target = effect_chain_target

func set_travel_range(travel_range_: float) -> void:
	travel_range_resource.set_value(travel_range_)
	travel_range_resource.max_value = travel_range_

## updates all collisions to reflect current target, team etc.
func update_collisions() -> void:
	Utility.update_hitbox_hurtbox_collision(hitbox, team, valid_effect_chain_target, _target_actor)


#endregion
