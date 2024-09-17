## constants used across the project.
##
## where an instance may exist with a similar name, e.g. STAT,
## we append "_TYPE" or similar to the constant's name, to help differentiation.
extends Node

########################
####### PATHS #########
######################

const PATH_SPRITE_FRAMES: String = "res://data/sprite_frames/"
const PATH_COMBAT_ACTIVES: String = "res://combat/actives/"

#########################
####### COMBAT #########
######################

## the reduction in force applied to a physics object when new force not being applied
const FRICTION: float = 10.3
## the linear damping applied to bodies
const LINEAR_DAMP: float = 5.0

## the standard amount for how long an [Aura] waits before looping.
const AURA_TICK_RATE: float = 0.33
## the standard amount of time to wait before applying regen.
const REGEN_TICK_RATE: float = 1.0
## min time to wait between combat active casts
const GLOBAL_CAST_DELAY: float = 0.33




########################
####### ENUMS #########
######################

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
	throwable,
	orbital,
	area_of_effect,
	aura
}

## the type of statistical breakdown of an entities physical properties.
##
## relates to [StatData].
enum STAT_TYPE {
	strength,
	defence,
	move_speed,
}

## similar to a stat, but one that can have a fluctuating value between 0 and max.
##
## relates to [Supply].
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
## usually used for [ABCBoonBane]s.
enum TRIGGER {
	on_hit_received,
	on_death,
	on_interval,
	on_application,
	on_use_combat_active,
	on_heal,
	on_summon,
	on_kill,
	on_move,
	on_deal_damage,
	on_receive_damage
}

## how a lifetime or duration is determined
enum DURATION_TYPE {
	time,
	applications,
	until_removed,
	permanent
}

## defined types of target preference
enum TARGET_PREFERENCE {
	any, ## anyone
	lowest_health, ## actor with lowest health
	highest_health,  ## actor with highest health
	weak_to_mundane,  ## actor with weakness to mundane damage type
	damaged,  ## actor that isnt full health
	nearest,  ## actor nearest caller
	furthest,  ## actor furthest from caller, but still in range
}

## different animation types for an actor
enum ACTOR_ANIMATION_NAME {
	cast,
	attack,
	death,
	idle,
	walk
}