## actions to trigger on the death of the actor.
## handles freeing the attached node.
@icon("res://components/functionals/death.png")
class_name DeathTrigger
extends Node

signal died

@export_group("Component Links")
@export var _root: Node  ## the node this component will operate on. @REQUIRED.
@export var _supply_container: SupplyContainerComponent  ## the supply container to refer to for the automatic trigger
@export_group("Automatic Triggers")
@export var _supply_type: Constants.SUPPLY_TYPE  ## the supply_type that triggers death on empty. Ignored if  _supply_container is empty.
@export_group("Results")
@export var _destroy_effect_spawner: SpawnerComponent  ## a spawner component for creating an effect on death.


func _ready() -> void:
	# check for mandatory properties set in editor
	assert(_root is Node, "Misssing `root`. ")

	# Connect the emptied signal on our supply to the activate function, if we have a resource.
	if _supply_container is SupplyContainerComponent:
		var supply = _supply_container.get_supply(_supply_type)
		if supply:
			supply.emptied.connect(activate)

func activate() -> void:
	# create an effect (from the spawner component) and free the actor
	if _destroy_effect_spawner is SpawnerComponent:
		_destroy_effect_spawner.spawn_scene(_root.global_position)

	died.emit()

	_root.queue_free()
