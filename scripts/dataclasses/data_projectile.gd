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
## max movement speed. with max_speed < accel < deccel we can get some random sidewinding movement,
## but still hit target. with move_speed >= accel we move straight to target
@export var max_speed: float
## how quickly we accelerate. uses delta, so will apply ~1/60th per frame to the velocity,
## up to max_speed.
@export var acceleration: float
## how quickly we decelerate. uses delta, so will apply ~1/60th per frame to the velocity.
## applied when max_speed is hit. should be >= acceleration.
@export var deceleration: float
## whether object can rotate
@export var lock_rotation: bool

@export_group("Throwable")
## how far the projectile can travel
@export var travel_range: float
## how fast we travel
@export var move_speed: float
## whether we track targets movement and follow, or not
@export var is_homing: bool

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

## definition of the [ProjectileThrowable] subclass. call after define.
func define_throwable(
	travel_range_: float,
	move_speed_: float,
	is_homing_: bool,
	max_speed_: float = 100.0,
	acceleration_: float = 100.0,
	deceleration_: float = 100.0,
	lock_rotation_: bool = true,
	) -> void:

	travel_range = travel_range_
	move_speed = move_speed_
	is_homing = is_homing_
	max_speed = max_speed_
	acceleration = acceleration_
	deceleration = deceleration_
	lock_rotation = lock_rotation_

#endregion



#endregion
