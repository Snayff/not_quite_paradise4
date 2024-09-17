## static data used across the project
extends Node

# NOTE: may want to load from external later
## storage of the static data
var _data: Dictionary  = {
	"projectile": {
		# NOTE: sprite frames are not unique, so specify
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

	},
	"combat_active": {
		# NOTE: icons are unique, so can load by name
		"slash": {
			"cast_type": Constants.CAST_TYPE.manual,
			"cast_supply": Constants.SUPPLY_TYPE.stamina,
			"cast_cost": 7,
			"valid_target_option": Constants.TARGET_OPTION.enemy,
			"valid_effect_option": Constants.TARGET_OPTION.enemy,
			"projectile_name": "slash",
			"cooldown_duration": 3,
			# orbitals only
			"max_projectiles": -1,
			"orbit_rotation_speed": -1,
			"orbit_radius": -1,
		},
		"icy_wind": {
			"cast_type": Constants.CAST_TYPE.manual,
			"cast_supply": Constants.SUPPLY_TYPE.stamina,
			"cast_cost": 10,
			"valid_target_option": Constants.TARGET_OPTION.self_,
			"valid_effect_option": Constants.TARGET_OPTION.enemy,
			"projectile_name": "icy_wind",
			"cooldown_duration": 5,
			# orbitals only
			"max_projectiles": -1,
			"orbit_rotation_speed": -1,
			"orbit_radius": -1,
		},
		"fireblast": {
			"cast_type": Constants.CAST_TYPE.manual,
			"cast_supply": Constants.SUPPLY_TYPE.stamina,
			"cast_cost": 10,
			"valid_target_option": Constants.TARGET_OPTION.enemy,
			"valid_effect_option": Constants.TARGET_OPTION.enemy,
			"projectile_name": "fireball",
			"cooldown_duration": 3,
			# orbitals only
			"max_projectiles": -1,
			"orbit_rotation_speed": -1,
			"orbit_radius": -1,
		},
		"circling_stars": {
			"cast_type": Constants.CAST_TYPE.auto,
			"cast_supply": Constants.SUPPLY_TYPE.stamina,
			"cast_cost": 10,
			"valid_target_option": Constants.TARGET_OPTION.self_,
			"valid_effect_option": Constants.TARGET_OPTION.enemy,
			"projectile_name": "fire_orb",
			"cooldown_duration": 1,
			# orbitals only
			"max_projectiles": 6,
			"orbit_rotation_speed": PI,
			"orbit_radius": 32,
		}

	},
	"actor": {
		# NOTE: sprite frames are not unique, so specify
		"wolf_rider" : {
			"sprite_frames": "wolf_rider.tres",
			"size": 16,
			"mass": 100.0,
			"acceleration": 100.0,
			"deceleration": 80.0,
			"actives": [
				"slash",
				"icy_wind",
				"fireblast",
				"circling_stars"
			],
			"supplies": {
				# SUPPLY_TYPE : [{max_value}, {regen_value}]
				Constants.SUPPLY_TYPE.health: [10, 0.1],
				Constants.SUPPLY_TYPE.stamina: [100, 0.0],
			},
			"stats": {
				Constants.STAT_TYPE.strength: 10,
				Constants.STAT_TYPE.defence: 5,
				Constants.STAT_TYPE.move_speed: 50,
			},
			"tags": [
				# Constants.COMBAT_TAG

			]
		},
		"horsey_rider" : {
			"sprite_frames": "horsey_rider.tres",
			"size": 16,
			"mass": 100.0,
			"acceleration": 100.0,
			"deceleration": 80.0,
			"actives": [
				"slash",
				"icy_wind",
				"fireblast",
				"circling_stars"
			],
			"supplies": {
				# SUPPLY_TYPE : [{max_value}, {regen_value}]
				Constants.SUPPLY_TYPE.health: [10, 0.1],
				Constants.SUPPLY_TYPE.stamina: [100, 0.0],
			},
			"stats": {
				Constants.STAT_TYPE.strength: 10,
				Constants.STAT_TYPE.defence: 5,
				Constants.STAT_TYPE.move_speed: 50,
			},
			"tags": [
				# Constants.COMBAT_TAG

			]
		}
	}
}

## get data in the form of a dict. passed by ref, so dont edit!
##
## primary_key: the first key in the library. "projectile", "actor", "combat_active" etc.
## secondary_key
func get_library_data(primary_key: String, secondary_key: String ) -> Dictionary:
	if not _data.has(primary_key):
		push_error("Library: primary key (", primary_key, ") not found.")
	if not _data[primary_key].has(secondary_key):
		push_error("Library: secondary key (", secondary_key, ") not found.")
	return _data[primary_key][secondary_key]

## get the range of the projectile.
##
## only [ProjectileThrowable] has range, so gives a base value for everything else
func get_projectile_range(projectile_name: String) -> float:
	var data: Dictionary = get_library_data("projectile", projectile_name)
	var max_range: float
	if data.has("max_range"):
		max_range = data["max_range"]
	else:
		# NOTE: this is slightly more than the smaller actor size. when using bigger sprites
		#		this wont work for melee.
		max_range = 24

	return max_range
