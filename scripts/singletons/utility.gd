## misc, helpful functions
extends Node


#region VARS

#endregion


#region FUNCS





func update_body_collisions(node: CollisionObject2D, team: Constants.TEAM, target_option: Constants.TARGET_OPTION, target_actor: CombatActor = null) -> void:
		# check we have necessary info
	if node is CollisionObject2D and team is Constants.TEAM and target_option is Constants.TARGET_OPTION:

		# only same team
		if target_option in [Constants.TARGET_OPTION.self_, Constants.TARGET_OPTION.ally]:
			node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_collision], team == Constants.TEAM.team1)
			node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_collision], team == Constants.TEAM.team2)

		# only other team
		elif target_option in [Constants.TARGET_OPTION.enemy]:
			node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_collision], team != Constants.TEAM.team1)
			node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_collision], team != Constants.TEAM.team2)

		# any team
		elif target_option in [Constants.TARGET_OPTION.anyone, Constants.TARGET_OPTION.other]:
			node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_collision], true)
			node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_collision], true)

		# only team of target
		elif target_option in [Constants.TARGET_OPTION.target]:
			if target_actor is CombatActor:
				var target_allegiance: Allegiance = target_actor.get_node_or_null("Allegiance")
				if target_allegiance is Allegiance:
					var target_team: Constants.TEAM = target_allegiance.team
					node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_collision], target_team == Constants.TEAM.team1)
					node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_collision], target_team == Constants.TEAM.team2)
					node.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_collision], target_team == Constants.TEAM.team1)
					node.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_collision], target_team == Constants.TEAM.team2)

		#breakpoint


func update_hitbox_hurtbox_collision(node: CollisionObject2D, team: Constants.TEAM, target_option: Constants.TARGET_OPTION, target_actor: CombatActor = null) -> void:
	# check we have necessary info
	if node is CollisionObject2D and team is Constants.TEAM and target_option is Constants.TARGET_OPTION:

		# only same team
		if target_option in [Constants.TARGET_OPTION.self_, Constants.TARGET_OPTION.ally]:
			node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], team == Constants.TEAM.team1)
			node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], team == Constants.TEAM.team2)

		# only other team
		elif target_option in [Constants.TARGET_OPTION.enemy]:
			node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], team != Constants.TEAM.team1)
			node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], team != Constants.TEAM.team2)

		# any team
		elif target_option in [Constants.TARGET_OPTION.anyone, Constants.TARGET_OPTION.other]:
			node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], true)
			node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], true)

		# only team of target
		elif target_option in [Constants.TARGET_OPTION.target]:
			if target_actor is CombatActor:
				var target_allegiance: Allegiance = target_actor.get_node_or_null("Allegiance")
				if target_allegiance is Allegiance:
					var target_team: Constants.TEAM = target_allegiance.team
					node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team1_hurtbox], target_team == Constants.TEAM.team1)
					node.set_collision_mask_value(Constants.COLLISION_LAYER_MAP[Constants.COLLISION_LAYER.team2_hurtbox], target_team == Constants.TEAM.team2)




#endregion
