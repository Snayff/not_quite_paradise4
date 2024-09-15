## spawn a scene
@icon("res://assets/node_icons/spawner.png")
class_name SpawnerComponent
extends Node2D


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
## The scene we want to spawn. If this is empty, nothing happens.
@export var scene: PackedScene
#endregion


#region VARS

#endregion


#region FUNCS
## Spawn an instance of the scene at a specific global position, adding it to the specified parent.
##
## If parent is left null then we fetch this scene's parent.
## returns the instance of the spawned scene.
func spawn_scene(global_spawn_position: Vector2 = global_position, parent = null) -> Node:
	# ignore if no scene to spawn
	if not scene is PackedScene:
		return

	if parent == null:
		parent = get_tree().current_scene

	var instance = scene.instantiate()

	# add it as a child of the parent
	parent.add_child(instance)

	# update the global position of the instance. (This must be done after adding it as a child)
	instance.global_position = global_spawn_position

	# return the instance
	return instance








#endregion
