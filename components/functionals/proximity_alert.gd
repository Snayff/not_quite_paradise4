## simple area2d that validates bodies based on targeting options
@icon("res://components/functionals/proximity.png")
class_name ProximityAlert
extends Area2D


#region SIGNALS
signal valid_body_entered(body: CollisionObject2D)
#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
@export_group("Targeting")
@export var _team: Constants.TEAM = Constants.TEAM.team1
@export var _target_option: Constants.TARGET_OPTION = Constants.TARGET_OPTION.enemy
@export_group("Details")
@export var _detection_radius: float = 8

#endregion


#region VARS

#endregion


#region FUNCS
func _ready() -> void:
	_update_collisions()

	body_entered.connect(_check_is_valid_target)

	# scale the shape
	if _detection_radius > 0:
		var shape: Shape2D = get_node("CollisionShape2D").shape
		var ratio: float = Utility.get_ratio_desired_vs_current(_detection_radius, shape)
		scale = Vector2(ratio, ratio)

## update the body collision layers/masks
func _update_collisions() -> void:
	if _team is Constants.TEAM and _target_option is Constants.TARGET_OPTION:
		Utility.update_body_collisions(self, _team, _target_option)

## check body is a valid target, emit valid_body_entered if it is and call _trigger
func _check_is_valid_target(body: CollisionObject2D) -> void:
	if Utility.target_is_valid(_target_option, self, body):
		valid_body_entered.emit(body)



#endregion
