## class desc
#@icon("")
class_name ActorSpawner
extends Node


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
@export_group("Details")
@export var _actor_to_spawn_as_player: String
@export var _actors_to_spawn: Array[String] = []
#endregion


#region VARS

#endregion


#region FUNCS
func _ready() -> void:
	# player
	var player = Factory.create_actor(_actor_to_spawn_as_player, Constants.TEAM.team1, Vector2(20, 20))
	player.set_as_player(true)

	# npcs
	var i = 1
	var team
	for actor_name in _actors_to_spawn:
		if i % 2 == 0:
			team = Constants.TEAM.team1
		else:
			team = Constants.TEAM.team2
		var pos = Vector2(20 + (i * 20), 20 + (i * 20))
		Factory.create_actor(actor_name, team, pos)

		i += 1







#endregion
