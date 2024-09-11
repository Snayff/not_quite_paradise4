## data for [ABCProjectile]
#@icon("")
class_name DataProjectile
extends Resource



#region EXPORTS
@export_group("Details")
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
#endregion


#region VARS

#endregion


#region FUNCS
## define the dataclass
func define(
	team_: Constants.TEAM,
	valid_hit_option_: Constants.TARGET_OPTION,
	size_: float = -1,
	max_bodies_can_hit_: int = 1,
	sprite_frames_: SpriteFrames
	) -> void:

	team = team_
	valid_hit_option = valid_hit_option_
	size = size_
	max_bodies_can_hit = max_bodies_can_hit_
	sprite_frames = sprite_frames_

#endregion



#endregion
