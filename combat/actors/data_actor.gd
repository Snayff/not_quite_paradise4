## data for [Actor]
@icon("res://projectiles/data_actor.png")
class_name DataActor
extends Resource


#region EXPORTS
@export_group("Base")
## the team that caused this projectile to be created.
@export var team: Constants.TEAM
## the animation for the actor
@export var sprite_frames: SpriteFrames
## how big the actor should be
@export var size: float
@export var mass: float
## how quickly we accelerate. uses delta, so will apply ~1/60th per frame to the velocity,
## up to max_speed.
@export var acceleration: float
## how quickly we decelerate. uses delta, so will apply ~1/60th per frame to the velocity.
## applied when max_speed is hit. should be >= acceleration.
@export var deceleration: float
@export var active_names: Array[String]
@export var passive_names: Array[String]
# SUPPLY_TYPE : [{max_value}, {regen_value}]
@export var supplies: Dictionary
# STAT_TYPE : {value}
@export var stats: Dictionary
@export var tags: Array[Constants.COMBAT_TAG]

#endregion

#region VARS

#endregion


#region FUNCS
## define the dataclass
func define(
	team_: Constants.TEAM,
	sprite_frames_: SpriteFrames,
	size_: float,
	mass_: float,
	acceleration_: float,
	deceleration_: float,
	actives_: Array[String],
	supplies_: Dictionary,
	stats_: Dictionary,
	tags_: Array[Constants.COMBAT_TAG]

	) -> void:

	team = team_
	sprite_frames = sprite_frames_
	size = size_
	mass = mass_
	acceleration = acceleration_
	deceleration = deceleration_
	active_names = actives_
	supplies = supplies_
	stats = stats_
	tags = tags_

#endregion
