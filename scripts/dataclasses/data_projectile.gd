## class desc
#@icon("")
class_name DataProjectile
extends Node


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
@export_group("Details")
@export var team: Constants.TEAM
@export var valid_hit_option: Constants.TARGET_OPTION  ## who the projectile can hit
@export var size: float
@export var max_bodies_hit: int
#endregion


#region VARS

#endregion


#region FUNCS
## define the dataclass
func define(
	team_: Constants.TEAM,
	valid_hit_option_: Constants.TARGET_OPTION,
	size_: float = -1,
	max_bodies_hit_: int = 1,
	) -> void:

	team = team_
	valid_hit_option = valid_hit_option_
	size = size_
	max_bodies_hit = max_bodies_hit_








#endregion
