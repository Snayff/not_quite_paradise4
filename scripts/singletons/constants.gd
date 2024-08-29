## constants used across the project.
##
## where an instance may exist with a similar name, e.g. STAT, we append "_TYPE" or similar to the constant's name, to help differentiation.
extends Node

const FRICTION: float = 10.3 ## the reduction in force applied to a physics object when new force not being applied

## the team the entity is on
enum TEAM {
	team1,
	team2
}

## the used collision layers
enum COLLISION_LAYER {
	team1_hitbox_hurtbox,
	team1_body,
	team2_hitbox_hurtbox,
	team2_body,
}

## collision layers mapped to their layer number (not bit value)
const COLLISION_LAYER_MAP: Dictionary = {
	COLLISION_LAYER.team1_hitbox_hurtbox: 1,
	COLLISION_LAYER.team1_body: 2,
	COLLISION_LAYER.team2_hitbox_hurtbox: 3,
	COLLISION_LAYER.team2_body: 4,
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

## how a [CombatActive] is cast
enum CAST_TYPE {
	manual,
	auto,
}

## how a set of effects in a [CombatActive] are delivered
enum EFFECT_DELIVERY_METHOD {
	direct_to_target,
	projectile,
	orbital,
	melee,
}

## the type of statistical breakdown of an entities physical properties.
##
## relates to [StatData].
enum STAT_TYPE {
	strength,
	defence
}

## similar to a stat, but one that can have a fluctuating value between 0 and max.
##
## relates to [SupplyComponent].
enum SUPPLY_TYPE {
	health,
	stamina
}

## how to mathematically apply a modifier
enum MATH_MOD_TYPE {
	add,
	multiply
}

## the things that can cause a reaction.
##
## usually used for [BoonBane]s.
enum TRIGGER {
	on_hit_received,
	on_death,
	on_interval,
}

## how a lifetime or duration is determined
enum DURATION_TYPE {
	time,
	applications,
	until_removed,
	permanent
}
