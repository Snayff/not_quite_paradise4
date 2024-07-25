## actions to trigger on the death of the actor.
## handles freeing the actor.
class_name DeathTrigger
extends Node


@export var root: Node  ## the node this component will operate on
@export var resource: ResourceComponent  ## the resource that triggers death on empty. @OPTIONAL.
@export var destroy_effect_spawner: SpawnerComponent  ## a spawner component for creating an effect on death. @OPTIONAL.


func _ready() -> void:
	# check for mandatory properties set in editor
	assert(root is Node, "Misssing `root`. ")

	# Connect the the no health signal on our stats to the activate function, if we have a resource.
	if resource is ResourceComponent:
		resource.emptied.connect(activate)

func activate() -> void:
	# create an effect (from the spawner component) and free the actor
	if destroy_effect_spawner is SpawnerComponent:
		destroy_effect_spawner.spawn(root.global_position)

	root.queue_free()
