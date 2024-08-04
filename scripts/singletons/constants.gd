extends Node

const  COMBAT_INIT_TIME: float = 0.5  # num seconds to allow everything to load in combat. some components trigger before others have setup properly, so use this delay.

## the team the entity is on
enum TEAM {
	team1,
	team2
}

## the used collision layers
enum COLLISION_LAYER {
	team1_hurtbox,
	team1_collision,
	team2_hurtbox,
	team2_collision,
}

## collision layers mapped to their layer number (not bit value)
const COLLISION_LAYER_MAP: Dictionary = {
	COLLISION_LAYER.team1_hurtbox: 1,
	COLLISION_LAYER.team1_collision: 2,
	COLLISION_LAYER.team2_hurtbox: 3,
	COLLISION_LAYER.team2_collision: 4,
}

## target options
enum TARGET_OPTION {
	self_,
	ally,
	enemy,
	other,
	anyone,
	target,
}

## tags that denote current properties
enum COMBAT_TAG {
	alive,
	dead,
	out_of_stamina,
	actor,
}


## how an entity moves in the world
enum MOVEMENT_UPDATE_TYPE {
	physics,
	transform,
}
