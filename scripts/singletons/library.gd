## static data used across the project
extends Node

## storage of the static data # NOTE: may want to load from external later
var _data: Dictionary  = {
	"projectile" : {
		"fireball" : {
			"subclass": "throwable",
			"sprite_frames": "fireball.tres",
			"valid_hit_option": Constants.TARGET_OPTION.enemy,
			"size": 8,
			"max_bodies_can_hit": 1,
			"travel_range": 100.0,
			"move_speed": 50.0,
		}
	}
}

## get data of a projectile. pass by ref, so dont edit!
func get_projectile_data(projectile_name: String) -> Dictionary:
	return _data["projectile"][projectile_name]
