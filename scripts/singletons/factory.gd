## global factory for standardised, simplified object production
extends Node

# N.B. can't preload with variable, so all hardcoded
const _PROJECTILE_THROWABLE: PackedScene = preload("res://scenes/templates/projectile_throwable.tscn")



#region VARS

#endregion


#region FUNCS
func create_projectile(projectile_name: String, team: Constants.TEAM) -> ABCProjectile:
	# get base info
	var dict_data: Dictionary = Library.get_projectile_data(projectile_name)
	var data_class: DataProjectile = DataProjectile.new()
	data_class.define(
		team,
		dict_data["valid_hit_option"],
		Utility.get_sprite_frame(dict_data["sprite_frames"]),
		dict_data["size"],
		dict_data["max_bodies_can_hit"]
	)

	# get specific subclass
	var projectile: ABCProjectile
	match data_class["subclass"]:
		"throwable":
			# finish setting up data class
			data_class.define_throwable(
				dict_data["travel_range"],
				dict_data["move_speed"]
			)

			# create and setup instance
			projectile = _PROJECTILE_THROWABLE.instantiate() as ProjectileThrowable
			projectile.setup(data_class)

		_:
			push_error("Factory: projectile subclass unknown.")

	return projectile








#endregion