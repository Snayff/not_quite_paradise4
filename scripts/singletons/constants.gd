extends Node

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

## collision layers mapped to their layer number
const COLLISION_LAYER_MAP: Dictionary = {
	COLLISION_LAYER.team1_hurtbox: 1,
	COLLISION_LAYER.team1_collision: 2,
	COLLISION_LAYER.team2_hurtbox: 4,
	COLLISION_LAYER.team2_collision: 8,
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
