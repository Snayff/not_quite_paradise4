## static data used across the project
extends Node

# NOTE: may want to load from external later
## storage of the static data
var _data: Dictionary  = {
	"projectile": {
		"fireball": {
			"effect_delivery_method": Constants.EFFECT_DELIVERY_METHOD.throwable,
			# base attrs
			"sprite_frames": "fireball.tres",
			"valid_hit_option": Constants.TARGET_OPTION.enemy,
			"size": 8,
			"max_bodies_can_hit": 1,
			# throwable attrs
			"max_range": 100.0,
			"move_speed": 50.0,
			"is_homing": false,
			"max_speed": 100.0,
			"acceleration": 1000.0,
			"deceleration": 2000.0,
			"lock_rotation": true,
		},
		"explosion": {
			"effect_delivery_method": Constants.EFFECT_DELIVERY_METHOD.area_of_effect,
			# base attrs
			"sprite_frames": "explosion.tres",
			"valid_hit_option": Constants.TARGET_OPTION.anyone,
			"size": 16,
			"max_bodies_can_hit": -1,
			# aoe attrs
			"application_frame": 0
		},
		"icy_wind": {
			"effect_delivery_method": Constants.EFFECT_DELIVERY_METHOD.aura,
			# base attrs
			"sprite_frames": "icy_wind.tres",
			"valid_hit_option": Constants.TARGET_OPTION.enemy,
			"size": 32,
			"max_bodies_can_hit": -1,
			# aura attrs
			"application_frame": 2,
			"lifetime": 3.0,
		},
		"fire_orb": {
			"effect_delivery_method": Constants.EFFECT_DELIVERY_METHOD.orbital,
			# base attrs
			"sprite_frames": "fireball.tres",
			"valid_hit_option": Constants.TARGET_OPTION.enemy,
			"size": 8,
			"max_bodies_can_hit": 1,
		},
		"slash": {
			"effect_delivery_method": Constants.EFFECT_DELIVERY_METHOD.area_of_effect,
			# base attrs
			"sprite_frames": "slash.tres",
			"valid_hit_option": Constants.TARGET_OPTION.enemy,
			"size": 16,
			"max_bodies_can_hit": -1,
			# aoe attrs
			"application_frame": 1
		},

	}
}

## get data of a projectile. passed by ref, so dont edit!
func get_projectile_data(projectile_name: String) -> Dictionary:
	if not _data["projectile"].has(projectile_name):
		push_error("Library: projectile name (", projectile_name, ") not found.")
	return _data["projectile"][projectile_name]

## get the range of the projectile.
##
## only [ProjectileThrowable] has range, so gives a base value for everything else
func get_projectile_range(projectile_name: String) -> float:
	var data: Dictionary = get_projectile_data(projectile_name)
	var max_range: float
	if data.has("max_range"):
		max_range = data["max_range"]
	else:
		# NOTE: this is slightly more than the smaller actor size. when using bigger sprites
		#		this wont work for melee.
		max_range = 24

	return max_range
