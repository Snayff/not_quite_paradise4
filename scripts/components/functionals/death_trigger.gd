## actions to trigger on the death of the actor.
## handles freeing the attached node.
@icon("res://assets/node_icons/death.png")
class_name DeathTrigger
extends Node

@export_category("Component Links")
@export var _root: Node  ## the node this component will operate on#
@export_category("Automatic Triggers")
@export var _resource: ResourceComponent  ## the resource that triggers death on empty. @OPTIONAL.
@export_category("Results")
@export var _destroy_effect_spawner: SpawnerComponent  ## a spawner component for creating an effect on death. @OPTIONAL.


func _ready() -> void:
	# check for mandatory properties set in editor
	assert(_root is Node, "Misssing `root`. ")

	# Connect the the no health signal on our stats to the activate function, if we have a resource.
	if _resource is ResourceComponent:
		_resource.emptied.connect(activate)

func activate() -> void:
	# create an effect (from the spawner component) and free the actor
	if _destroy_effect_spawner is SpawnerComponent:
		_destroy_effect_spawner.spawn_scene(_root.global_position)

	_root.queue_free()
