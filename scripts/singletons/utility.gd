## misc, helpful functions
extends Node


#region VARS

#endregion


#region FUNCS
## set the collision layers and masks, based on team and targeting, to the relevant "_body" collision layers.
func update_body_collisions(
	node: CollisionObject2D,
	team: Constants.TEAM,
	target_option: Constants.TARGET_OPTION,
	target_actor: CombatActor = null,
	add_layers: bool = true,
	add_masks: bool = true,
	) -> void:
	_update_collisions(
		node,
		team,
		target_option,
		Constants.COLLISION_LAYER.team1_body,
		Constants.COLLISION_LAYER.team2_body,
		target_actor,
		add_layers,
		add_masks
	)

## set the collision layers and masks, based on team and targeting, to the relevant "_hitbox_hurtbox" collision layers.
func update_hitbox_hurtbox_collision(
	node: CollisionObject2D,
	team: Constants.TEAM,
	target_option: Constants.TARGET_OPTION,
	target_actor: CombatActor = null,
	add_layers: bool = true,
	add_masks: bool = true,
	) -> void:
	_update_collisions(
		node,
		team,
		target_option,
		Constants.COLLISION_LAYER.team1_hitbox_hurtbox,
		Constants.COLLISION_LAYER.team2_hitbox_hurtbox,
		target_actor,
		add_layers,
		add_masks
	)

## unified func to update collisions
func _update_collisions(
	node: CollisionObject2D,
	team: Constants.TEAM,
	target_option: Constants.TARGET_OPTION,
	team1: Constants.COLLISION_LAYER,
	team2: Constants.COLLISION_LAYER,
	target_actor: CombatActor = null,
	add_layers: bool = true,
	add_masks: bool = true,
	) -> void:
	if not(node is CollisionObject2D and team is Constants.TEAM and target_option is Constants.TARGET_OPTION):
		push_warning("Utility: args of incorrect type.")
		return

	# clear existing - 1-32 are the possible layers/masks
	for i in range(1, 32):
		node.set_collision_layer_value(i, false)
		node.set_collision_mask_value(i, false)

	# LAYERS
	if add_layers:
		node.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[team1], team == Constants.TEAM.team1)
		node.set_collision_layer_value(Constants.COLLISION_LAYER_MAP[team2], team == Constants.TEAM.team2)

	# MASKS
	if not add_masks:
		return

	# only same team
	if target_option in [Constants.TARGET_OPTION.self_, Constants.TARGET_OPTION.ally]:
		node.set_collision_mask_value(
			Constants.COLLISION_LAYER_MAP[team1], team == Constants.TEAM.team1
		)
		node.set_collision_mask_value(
			Constants.COLLISION_LAYER_MAP[team2], team == Constants.TEAM.team2
		)

	# only other team
	elif target_option in [Constants.TARGET_OPTION.enemy]:
		node.set_collision_mask_value(
			Constants.COLLISION_LAYER_MAP[team1], team != Constants.TEAM.team1
		)
		node.set_collision_mask_value(
			Constants.COLLISION_LAYER_MAP[team2], team != Constants.TEAM.team2
		)

	# any team
	elif target_option in [Constants.TARGET_OPTION.anyone, Constants.TARGET_OPTION.other]:
		node.set_collision_mask_value(
			Constants.COLLISION_LAYER_MAP[team1], true
		)
		node.set_collision_mask_value(
			Constants.COLLISION_LAYER_MAP[team2], true
		)

	# only team of target
	elif target_option in [Constants.TARGET_OPTION.target]:
		if target_actor is CombatActor:
			var target_allegiance: Allegiance = target_actor.get_node_or_null("Allegiance")
			if target_allegiance is Allegiance:
				var target_team: Constants.TEAM = target_allegiance.team
				node.set_collision_mask_value(
					Constants.COLLISION_LAYER_MAP[team1], target_team == Constants.TEAM.team1
				)
				node.set_collision_mask_value(
					Constants.COLLISION_LAYER_MAP[team2], target_team == Constants.TEAM.team2
				)
				node.set_collision_layer_value(
					Constants.COLLISION_LAYER_MAP[team1], target_team == Constants.TEAM.team1
				)
				node.set_collision_layer_value(
					Constants.COLLISION_LAYER_MAP[team2], target_team == Constants.TEAM.team2
				)

## check target is of type expected, as per [TARGET_OPTION]
##
## Only check against the items that identify self, not self, or target, as the [TEAM] element should be handled by collision layer/mask.
func target_is_valid(target_option: Constants.TARGET_OPTION, originator: Node2D, target: Node2D, target_actor: CombatActor = null) -> bool:
	if target_option == Constants.TARGET_OPTION.self_:
		if originator == target:
			return true
		else:
			return false

	elif target_option == Constants.TARGET_OPTION.other:
		if originator != target:
			return true
		else:
			return false

	elif target_option == Constants.TARGET_OPTION.target:
		if target_actor == target:
			return true
		else:
			return false

	## ignore other target checks as already filtered by collision layers
	return true

## get the enum name from its value.
##
## get_enum_name(TEAM, TEAM.team1) -> "team1"
func get_enum_name(enum_: Variant, value: Variant) -> String:
	return enum_.keys()[value]

## get the % difference between the current shape "size" and the desired size.
##
## uses different properties based on the shape type.
func get_ratio_desired_vs_current(desired_size: float, shape: Shape2D) -> float:
	var ratio: float = 1
	if shape is CircleShape2D:
		ratio = get_percentage_change(desired_size, shape.radius * 2)

	elif shape is SegmentShape2D:
		var size: float = shape.a.distance_to(shape.b)
		ratio = get_percentage_change(desired_size, size)

	elif shape is CapsuleShape2D:
		ratio = get_percentage_change(desired_size, shape.height)

	return ratio

# the change in value, expressed as variance from 1. e.g. reduction by 13 points is 0.87.
func get_percentage_change(new_value: float, old_value: float) -> float:
	var ratio: float = 1
	if new_value > old_value:
		ratio = _get_percentage_increase(new_value, old_value)
	else:
		ratio = _get_percentage_decrease(new_value, old_value)

	return ratio


func _get_percentage_increase(new_value: float, old_value: float) -> float:
	return 1.0 + (new_value - old_value) / old_value

func _get_percentage_decrease(new_value: float, old_value: float) -> float:
	return 1 - ((old_value - new_value) / old_value)

## load a [SpriteFrames] from disk
func get_sprite_frame(sprite_frame_name: String) -> SpriteFrames:
	var sprite_frames: SpriteFrames = load(Constants.PATH_SPRITE_FRAMES.path_join(sprite_frame_name))
	if sprite_frames is not SpriteFrames:
		push_error("Utility: sprite_frames (", sprite_frame_name, ") not found.")
	return sprite_frames

#endregion
