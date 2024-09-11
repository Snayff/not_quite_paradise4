## A projectile that moves, expires on reaching end of travel range,
## triggers effects on hit and on death
@icon("res://assets/node_icons/projectile.png")
class_name ProjectileThrowable
extends ABCProjectile


#region SIGNALS
## emitted when resolved
signal hit_valid_target(hurtbox: HurtboxComponent)
#endregion


#region ON READY (for direct children only)
@onready var _on_hit_effect_spawner: SpawnerComponent = $OnHitEffectSpawner
@onready var _on_death_effect_spawner: SpawnerComponent = $OnDeathEffectSpawner
@onready var _supply_container: SupplyContainerComponent = $SupplyContainerComponent
@onready var _death_trigger: DeathTrigger = $DeathTrigger
@onready var _movement_component: PhysicsMovementComponent = $PhysicsMovementComponent

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
# @export_group("Details")
#endregion


#region VARS
## the amount of stamina we can drain before expiry
var travel_range: float

#endregion


#region FUNCS
# TODO: take a subclass of DataProjectile that also has specific things we need here
func setup(data: DataProjectile) -> void:
	super.setup(data)

func _on_hit(hurtbox: HurtboxComponent) -> void:
	pass

func activate() -> void:
	_set_collision_disabled(false)
	_set_hitbox_disabled(false)

## update the stamina value of the supply container and the associated max range
func set_travel_range(travel_range: float) -> void:
	@warning_ignore("narrowing_conversion")  # happy with reduced precision
	_supply_container.get_supply(Constants.SUPPLY_TYPE.stamina).set_value(travel_range)
	@warning_ignore("narrowing_conversion")  # happy with reduced precision
	_supply_container.get_supply(Constants.SUPPLY_TYPE.stamina).max_value = travel_range




#endregion
