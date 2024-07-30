@icon("res://assets/node_icons/spawner.png")
## spawn a scene at Spawner position
class_name SpawnerComponent
extends Node2D


@export var scene: PackedScene  ## The scene we want to spawn
@export var node: Node  ## the node we want to duplicate, e.g. a template projectile.


var _is_disabled: bool = false


func _ready() -> void:
	# check for mandatory properties set in editor
	if not scene is PackedScene and not node is Node:
		#print_debug("EffectSpawner has nothing to spawn. Is this intended? ")
		_is_disabled = true


## Spawn an instance of the scene at a specific global position on a parent
##
## By default, the parent is the current "main" scene , but can pass in an alternative parent if you so choose.
## returns the instance of the spawned scene.
func spawn_scene(global_spawn_position: Vector2 = global_position, parent: Node = get_tree().current_scene) -> Node:
	if _is_disabled:
		return null

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
