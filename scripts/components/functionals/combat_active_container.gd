## interface for a collection of [CombatActive]s.
##
## CombatActives should be added as children.
@icon("res://assets/node_icons/combat_active_container.png")
class_name CombatActiveContainerComponent
extends Node


#region SIGNALS
signal has_ready_active
#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
@export_group("Component Links")
@export var _creator: CombatActor  ## who created this active
@export var _allegiance: Allegiance  ## creator's allegiance component
@export var _projectile_position: Marker2D  ##  projectile spawn location. Must have in order for a [CombatActive] to be able to use `projectile` delivery method.
#@export_group("Details")
#endregion


#region VARS
var _actives: Array[CombatActive]  ## all combat actives.
var _ready_actives: Array[CombatActive]  ## actives that are ready to cast - may not have a target.
#endregion


#region FUNCS
func _ready() -> void:
	# check for mandatory properties set in editor
	assert(_creator is CombatActor, "Misssing `creator`.")
	assert(_allegiance is Allegiance, "Misssing `allegiance`.")
	assert(_projectile_position is Marker2D, "Misssing `_projectile_position`.")

	_update_actives_array()
	_update_actives_with_component_links()
	_connect_to_actives_signals()

## get all children that are [CombatActive]s and put into _active
func _update_actives_array() -> void:
	for child in get_children():
		if child is CombatActive:
			_actives.append(child)

## pass through the required component links to all actives
func _update_actives_with_component_links() -> void:
	for active in _actives:
		active.creator = _creator
		active.allegiance = _allegiance
		active.projectile_position = _projectile_position

func _connect_to_actives_signals() -> void:
	for active in _actives:
		active.now_ready.connect(func(): _ready_actives.append(active))
		active.now_ready.connect(has_ready_active.emit)

## get an active by its class_name. returns null if nothing matching found.
func get_active(active_name: String) -> CombatActive:
	for active in _actives:
		if active.get_global_name() == active_name:
			return active

	return null

## picks a random, ready active and casts it, if there is a target. If no target, nothing happens.
func cast_random_ready_active() -> void:
	var random_active: CombatActive = _ready_actives.pick_random()
	cast_ready_active(random_active.get_global_name())

## casts the specified active, if it is ready and there is a target. If not, nothing happens.
func cast_ready_active(active_name: String) -> void:
	var active: CombatActive = get_active(active_name)
	if active.is_ready and active.target_actor:
		active.cast()
		_ready_actives.erase(active)








#endregion
