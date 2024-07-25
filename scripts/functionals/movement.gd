## apply movement to the actor
class_name MovementComponent
extends Node

@export var rigid_body_2d: RigidBody2D
@export var root: Node2D

## the actor being targeted. use when target updating required. preferred over target_position.
var target_actor: CombatActor
## the position being targeted.
var target_position: Vector2

func _physics_process(delta: float) -> void:

	var direction: Vector2 = Vector2.ZERO
	if target_actor is CombatActor:
		direction = root.global_position - target_actor.position
	elif  target_position != Vector2.ZERO:
		direction = root.global_position - target_position

	rigid_body_2d.apply_central_impulse(direction)
