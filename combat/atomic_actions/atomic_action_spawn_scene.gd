## spawn a scene on a [CombatActor], using the CombatActor's ReusableSpawner (a [SpawnerComponent]).
##
## used for deferred spawning of a scene.
#@icon("")
class_name AtomicActionSpawnScene
extends ABCAtomicAction


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
# @export_group("Details")  # feel free to rename category
#endregion


#region VARS
var scene: PackedScene
#endregion


#region FUNCS
func apply(target: CombatActor) -> void:
	var spawner: SpawnerComponent = target.get("reusable_spawner")
	if spawner is SpawnerComponent:
		spawner.scene = scene
		spawner.spawn_scene(target.global_position)








#endregion
