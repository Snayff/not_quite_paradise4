## data for [ABCProjectile]
#@icon("")
class_name DataProjectile
extends Resource



#region EXPORTS
@export_group("Base")
## the team that caused this projectile to be created.
@export var team: Constants.TEAM
## who the projectile can hit
@export var valid_hit_option: Constants.TARGET_OPTION
## how big the projectile should be
@export var size: float
## how many bodies can be hit before expiry
@export var max_bodies_can_hit: int
## the animation for the projectile
@export var sprite_frames: SpriteFrames
@export_group("Throwable")
## how far the projectile can travel
@export var travel_range: float
## how fast we travel
var move_speed: float
## whether we track targets movement and follow, or not
var is_homing: bool
#endregion


#region VARS

#endregion


#region FUNCS
## define the dataclass
func define(
	team_: Constants.TEAM,
	valid_hit_option_: Constants.TARGET_OPTION,
	sprite_frames_: SpriteFrames,
	size_: float = -1,
	max_bodies_can_hit_: int = 1,

	) -> void:

	team = team_
	valid_hit_option = valid_hit_option_
	size = size_
	max_bodies_can_hit = max_bodies_can_hit_
	sprite_frames = sprite_frames_

## definition of the [ProjectileThrowable] subclass
func define_throwable(
	travel_range_: float,
	move_speed_: float,
	is_homing_: bool,
	) -> void:

	travel_range = travel_range_
	move_speed = move_speed_
	is_homing = is_homing_

#endregion



#endregion
