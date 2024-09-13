## static data used across the project
extends Node

## storage of the static data # NOTE: may want to load from external later
var _data: Dictionary  = {
	"projectile": {
		"fireball": {
			"subclass": "throwable",
			# base attrs
			"sprite_frames": "fireball.tres",
			"valid_hit_option": Constants.TARGET_OPTION.enemy,
			"size": 8,
			"max_bodies_can_hit": 1,
			# throwable attrs
			"travel_range": 100.0,
			"move_speed": 50.0,
			"is_homing": false,
			"max_speed": 100.0,
			"acceleration": 1000.0,
			"deceleration": 2000.0,
			"lock_rotation": true,
		},
		"explosion": {
			"subclass": "aoe",
			# base attrs
			"sprite_frames": "explosion.tres",
			"valid_hit_option": Constants.TARGET_OPTION.anyone,
			"size": 8,
			"max_bodies_can_hit": -1,
			# aoe attrs
			"application_frame": 0
		},
		"icy_wind": {
			"subclass": "aura",
			# base attrs
			"sprite_frames": "icy_wind.tres",
			"valid_hit_option": Constants.TARGET_OPTION.enemy,
			"size": 320,
			"max_bodies_can_hit": -1,
			# aura attrs
			"application_frame": 2,
			"lifetime": 3.0,
		},

	}
}

## get data of a projectile. passed by ref, so dont edit!
func get_projectile_data(projectile_name: String) -> Dictionary:
	return _data["projectile"][projectile_name]
