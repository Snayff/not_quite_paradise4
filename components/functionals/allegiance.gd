## info regarding the team the actor is on.
## updates linked components to reflect the team.
@icon("res://components/functionals/allegiance.png")
class_name Allegiance
extends Node

@export_group("Component Links")
@export var _root: Actor
# FIXME: this is dumb. Why would the allegiance be setting the collisions of something else? bad.
## if set, updates the collision layers based on team.
@export var hurtbox: HurtboxComponent


@export_group("Details")
@export var team: Constants.TEAM


func _ready() -> void:
	# check for mandatory properties set in editor
	assert(_root is Actor, "Misssing `_root`.")

	_root.add_to_group(Utility.get_enum_name(Constants.TEAM, team), true)

	if hurtbox is HurtboxComponent:
		_update_hurtbox_collisions()

## update collisions of linked hurtbox based on allegiance
func _update_hurtbox_collisions() -> void:
	# TODO: update to use Utility methods
	if team == Constants.TEAM.team1:
		hurtbox.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hitbox_hurtbox], true)
		hurtbox.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hitbox_hurtbox], false)
	elif team == Constants.TEAM.team2:
		hurtbox.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hitbox_hurtbox], false)
		hurtbox.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hitbox_hurtbox], true)
	else:
		push_error("Allegiance: Team selected in Allegiance not found.")
