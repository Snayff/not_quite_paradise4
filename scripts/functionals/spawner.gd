@icon("res://assets/node_icons/spawner.png")
## spawn a scene at Spawner position
class_name SpawnerComponent
extends Node2D


@export var scene: PackedScene  ## The scene we want to spawn
@export var node: Node  ## the node we want to duplicate, e.g. a template projectile.


func _ready() -> void:
	# check for mandatory properties set in editor
	assert(scene is PackedScene or node is Node, "Misssing at least one of `scene` or `node. ")

## spawn either the scene or the node, preferring the scene.
## useful when whether there is a scene or node is not known.
func spawn(global_spawn_position: Vector2 = global_position, parent: Node = get_tree().current_scene) -> Variant:
	if scene is PackedScene:
		return spawn_scene(global_spawn_position, parent)
	elif node is Node:
		return spawn_duplicate_node(global_spawn_position, parent)
	else:
		push_error("Nothing to spawn.")
		return null

## Spawn an instance of the scene at a specific global position on a parent
##
## By default, the parent is the current "main" scene , but can pass in an alternative parent if you so choose.
## returns the instance of the spawned scene.
func spawn_scene(global_spawn_position: Vector2 = global_position, parent: Node = get_tree().current_scene) -> Node:
	assert(scene is PackedScene, "Error: The scene export was never set on this spawner component.")

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

## Spawn a duplicate of the node at a specific global position on a parent
##
## By default, the parent is the current "main" scene , but can pass in an alternative parent if you so choose.
## returns the instance of the spawned scene.
func spawn_duplicate_node(global_spawn_position: Vector2 = global_position, parent: Node = get_tree().current_scene) -> Node:
	assert(node != null, "Error: The scene export was never set on this spawner component.")

	var new_node = node.duplicate()

	# Add it as a child of the parent
	parent.add_child(new_node)

	# Update the global position of the instance.
	# (This must be done after adding it as a child)
	new_node.global_position = global_spawn_position

	# Return the instance in case we want to perform any other operations
	# on it after instancing it.
	return new_node
