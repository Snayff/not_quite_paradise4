## actions to trigger on the death of the actor.
## handles freeing the actor.
class_name DeathTrigger
extends Node


@export var root_actor: CombatActor  ## the actor this component will operate on
@export var resource: ResourceComponent  ## the resource that triggers death on empty
@export var destroy_effect_spawner: SpawnerComponent  ## a spawner component for creating an effect on death


func _ready() -> void:
	# Connect the the no health signal on our stats to the destroy function
	resource.emptied.connect(destroy)

func destroy() -> void:
	# create an effect (from the spawner component) and free the actor
	destroy_effect_spawner.spawn(root_actor.global_position)
	root_actor.queue_free()
