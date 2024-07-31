## class spawn a scene on a [CombatActor], using the CombatActor's ReusableSpawner (a [SpawnerComponent]).
#@icon("")
class_name SpawnSceneEffect
extends Effect


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_category("Component Links")
# @export var
#
# @export_category("Details")  # feel free to rename category
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
