## info regarding the team the actor is on.
## updates linked components to reflect the team.
class_name Allegiance
extends Node

@onready var hurtbox_component: HurtboxComponent = %HurtboxComponent


@export var root_actor: CombatActor
@export var team: Constants.TEAM


func _ready() -> void:
	root_actor.add_to_group(str("team_", team), true)

	if hurtbox_component is HurtboxComponent:
		if team == Constants.TEAM.ally:
			hurtbox_component.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.ally_hurtbox], true)
			hurtbox_component.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.enemy_hurtbox], false)
		elif team == Constants.TEAM.enemy:
			hurtbox_component.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.ally_hurtbox], false)
			hurtbox_component.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.enemy_hurtbox], true)
		else:
			push_error("Team selected in Allegiance not found.")
