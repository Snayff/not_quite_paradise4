extends Node

## the team the entity is on
enum TEAM {
	ally,
	enemy
}

## the used collision layers
enum COLLISION_LAYER {
	ally_hurtbox,
	ally_collision,
	enemy_hurtbox,
	enemy_collision,
}

## collision layers mapped to their layer number
const COLLISION_LAYER_MAP = {
	COLLISION_LAYER.ally_hurtbox: 1,
	COLLISION_LAYER.ally_collision: 2,
	COLLISION_LAYER.enemy_hurtbox: 4,
	COLLISION_LAYER.enemy_collision: 8,
}

## target options
enum TARGETS {
	self_,
	ally,
	enemy,
	other,
	anyone
}
