## actions to trigger on the death of the actor.
## handles freeing the actor.
class_name DeathTrigger
extends Node

## the actor this component will operate on
@export var actor: CombatActor

## the resource that triggers death on empty
@export var resource: ResourceComponent

## a spawner component for creating an effect on death
@export var destroy_effect_spawner: SpawnerComponent

func _ready() -> void:
	# Connect the the no health signal on our stats to the destroy function
	resource.emptied.connect(destroy)

func destroy() -> void:
	# create an effect (from the spawner component) and free the actor
	destroy_effect_spawner.spawn(actor.global_position)
	actor.queue_free()
