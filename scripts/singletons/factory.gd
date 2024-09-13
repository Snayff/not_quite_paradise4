## global factory for standardised, simplified object production
extends Node

# N.B. can't preload with variable, so all hardcoded
const _PROJECTILE_THROWABLE: PackedScene = preload("res://scenes/templates/projectile_throwable.tscn")
const _PROJECTILE_AOE: PackedScene = preload("res://scenes/templates/projectile_area_of_effect.tscn")


#region VARS

#endregion


#region FUNCS
func create_projectile(
	projectile_name: String,
	team: Constants.TEAM,
	on_hit_callable: Variant = null
	) -> ABCProjectile:
	# get base info
	var dict_data: Dictionary = Library.get_projectile_data(projectile_name)
	var data_class: DataProjectile = DataProjectile.new()
	data_class.define(
		team,
		dict_data["valid_hit_option"],
		Utility.get_sprite_frame(dict_data["sprite_frames"]),
		dict_data["size"],
		dict_data["max_bodies_can_hit"],
	)

	# get specific subclass
	var projectile: ABCProjectile
	match dict_data["subclass"]:
		"throwable":
			# finish setting up data class
			data_class.define_throwable(
				dict_data["travel_range"],
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

		"aoe":
			data_class.define_aoe(
				dict_data["application_frame"]
			)

			projectile = _PROJECTILE_AOE.instantiate() as ProjectileAreaOfEffect

			if on_hit_callable != null:
				projectile.hit_valid_targets.connect(on_hit_callable)
		_:
			push_error("Factory: projectile subclass unknown.")

	# create and setup instance

	projectile.ready.connect(projectile.setup.bind(data_class), CONNECT_ONE_SHOT)
	# TODO: find a better way to do this. Perhaps a top level projectiles node?
	get_tree().get_root().add_child(projectile)



	return projectile








#endregion
