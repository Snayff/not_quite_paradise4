## an active skill used in combat
class_name CombatActive
extends Node2D

@onready var hitbox_component: HitboxComponent = %HitboxComponent

@export var creator: CombatActor  ## who created this active
@export var valid_targets: Constants.TEAM  ## Constants.TEAM

func _ready() -> void:
	if hitbox_component is HitboxComponent:
		pass
		#if team == Constants.TEAM.team1:
			#hurtbox_component.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], true)
			#hurtbox_component.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], false)
		#elif team == Constants.TEAM.team2:
			#hurtbox_component.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], false)
			#hurtbox_component.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], true)
		#else:
			#push_error("Team selected in Allegiance not found.")
