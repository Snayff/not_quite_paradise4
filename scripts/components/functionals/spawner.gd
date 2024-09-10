## spawn a scene at Spawner position
@icon("res://assets/node_icons/spawner.png")
class_name SpawnerComponent
extends Node2D


@export var scene: PackedScene  ## The scene we want to spawn. If this is empty, nothing happens.


## Spawn an instance of the scene at a specific global position, adding it to the specified parent.
##
## If parent is left null then we fetch this scene's parent.
## returns the instance of the spawned scene.
func spawn_scene(global_spawn_position: Vector2 = global_position, parent = null) -> Node:
	if not scene is PackedScene:
		#push_warning("SpawnerComponent: Nothing to spawn.")
		return

	if parent == null:
		parent = get_tree().current_scene

	# Instance the scene
	var instance = scene.instantiate()


	# Add it as a child of the parent
	parent.add_child(instance)

	# Update the global position of the instance.
	# (This must be done after adding it as a child)
	instance.global_position = global_spawn_position

	# Return the instance in case we want to perform any other operations
	# on it after instancing it.
	return instance
