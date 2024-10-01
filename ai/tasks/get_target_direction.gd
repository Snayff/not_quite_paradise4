## get a direction towards or away from target
## [code]FAILURE[/code] if target is not valid.
@tool
extends BTAction

@export_group("Input")
@export var target_actor_var: StringName = &"target_actor"
@export_group("Output")
@export var target_direction_var: StringName = &"target_direction"
@export_group("Config")
@export_enum("towards", "away") var _movement_intent: String = "towards"

func _generate_name() -> String:
    return "GetTargetDirection: find direction %s %s ➜ %s as Vector2" % [
        _movement_intent,
        LimboUtility.decorate_var(target_actor_var),
        LimboUtility.decorate_var(target_direction_var)
    ]

func _tick(_delta: float) -> Status:
    var target_actor: Actor = blackboard.get_var(target_actor_var)
    if target_actor is not Actor:
        return FAILURE
    print("Target actor is %s" % target_actor)

    # FIXME: sometimes this isnt getting the direction away from the target, but is close
    #var direction: Vector2 = agent.global_position.direction_to(target_actor.global_position)
    var direction: Vector2 = agent.global_position
    direction.direction_to(target_actor.global_position)

    #var target_direction: Vector2
    #if _movement_intent == "away":
        ## invert to get move away direction
        #target_direction = -direction
    #else:
        #target_direction = direction

    blackboard.set_var(target_direction_var, direction)

    return SUCCESS
