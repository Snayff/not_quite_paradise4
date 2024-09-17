## global factory for standardised, simplified object production. holds production of objects
## required across the project
extends Node

# N.B. can't preload with variable, so all hardcoded
const _PROJECTILE_THROWABLE: PackedScene = preload(
	"res://combat/projectiles/projectile_throwable.tscn"
)
const _PROJECTILE_AOE: PackedScene = preload(
	"res://combat/projectiles/projectile_area_of_effect.tscn"
)
const _PROJECTILE_AURA: PackedScene = preload(
	"res://combat/projectiles/projectile_aura.tscn"
)
const _PROJECTILE_ORBITAL: PackedScene = preload(
	"res://combat/projectiles/projectile_orbital.tscn"
)
const _ACTOR: PackedScene = preload(
	"res://combat/actors/actor.tscn"
)


#region VARS

#endregion


#region FUNCS
## create an [ABCProjectile] at a given location on a given team.
func create_projectile(
	projectile_name: String,
	team: Constants.TEAM,
	spawn_pos: Vector2,
	on_hit_callable: Variant = null
	) -> ABCProjectile:
	# get base info
	var dict_data: Dictionary = Library.get_library_data("projectile", projectile_name)
	var data_class: DataProjectile = DataProjectile.new()
	data_class.define(
		team,
		dict_data["valid_hit_option"],
		Utility.get_sprite_frame("projectiles", dict_data["sprite_frames"]),
		dict_data["size"],
		dict_data["max_bodies_can_hit"],
	)

	# get specific subclass
	var projectile: ABCProjectile
	match dict_data["effect_delivery_method"]:
		Constants.EFFECT_DELIVERY_METHOD.throwable:
			# finish setting up data class
			data_class.define_throwable(
				dict_data["max_range"],
				dict_data["move_speed"],
				dict_data["is_homing"],
				dict_data["max_speed"],
				dict_data["acceleration"],
				dict_data["deceleration"],
				dict_data["lock_rotation"]
			)

			projectile = _PROJECTILE_THROWABLE.instantiate() as ProjectileThrowable

			if on_hit_callable != null:
				projectile.hit_valid_target.connect(on_hit_callable)

		Constants.EFFECT_DELIVERY_METHOD.area_of_effect:
			data_class.define_aoe(
				dict_data["application_frame"]
			)

			projectile = _PROJECTILE_AOE.instantiate() as ProjectileAreaOfEffect

			if on_hit_callable != null:
				projectile.hit_multiple_valid_targets.connect(on_hit_callable)

		Constants.EFFECT_DELIVERY_METHOD.aura:
			data_class.define_aura(
				dict_data["application_frame"],
				dict_data["lifetime"]
			)

			projectile = _PROJECTILE_AURA.instantiate() as ProjectileAura

			if on_hit_callable != null:
				projectile.hit_multiple_valid_targets.connect(on_hit_callable)

		Constants.EFFECT_DELIVERY_METHOD.orbital:
			projectile = _PROJECTILE_ORBITAL.instantiate() as ProjectileOrbital

			if on_hit_callable != null:
				projectile.hit_valid_target.connect(on_hit_callable)

		_:
			push_error(
				"Factory: projectile delivery type (",
				dict_data["effect_delivery_method"],
				" unknown."
			)

	# create and setup instance

	projectile.ready.connect(projectile.setup.bind(spawn_pos, data_class), CONNECT_ONE_SHOT)
	# TODO: find a better way to do this. Perhaps a top level projectiles node?
	get_tree().get_root().add_child(projectile)

	return projectile

## create an [Actor] at a given location on a given team.
func create_actor(
	actor_name: String,
	team: Constants.TEAM,
	spawn_pos: Vector2,
	) -> Actor:
	var actor: Actor = _ACTOR.instantiate()

	# get data from dict
	var dict_data: Dictionary =  Library.get_library_data("actor", actor_name)

	# put data into data class
	var data_class: DataActor = DataActor.new()
	data_class.define(
		team,
		Utility.get_sprite_frame("actors", dict_data["sprite_frames"]),
		dict_data["size"],
		dict_data["mass"],
		dict_data["acceleration"],
		dict_data["deceleration"],
		dict_data["actives"],
		dict_data["supplies"],
		dict_data["stats"],
		dict_data["tags"],
	)

	# connect ready to setup
	actor.ready.connect(actor.setup.bind(spawn_pos, data_class), CONNECT_ONE_SHOT)

	# add to actor container parent - if this works, do same for projectile


	# TODO:
	#		build actor.setup

	return actor

#endregion
