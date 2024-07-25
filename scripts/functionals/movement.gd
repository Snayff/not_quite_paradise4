## apply movement to the actor
class_name MovementComponent
extends Node

@export var rigid_body_2d: RigidBody2D
@export var root: Node2D


var target_actor: CombatActor  ## the actor being targeted. use when target updating required. preferred over target_position.
var target_position: Vector2  ## the position being targeted.
var direction: Vector2:
	set(value):
		return
	get:
		if target_actor is CombatActor:
			direction = root.global_position - target_actor.position
		elif  target_position != Vector2.ZERO:
			direction = root.global_position - target_position
		return direction
var distance_travelled: float = 0  ## how far we have travelled


func _ready() -> void:
	# check for mandatory properties set in editor
	assert(root is Node2D, "Misssing `root`. ")
	assert(rigid_body_2d is RigidBody2D, "Misssing `rigid_body_2d`. ")


func _physics_process(delta: float) -> void:
	# move towards target
	rigid_body_2d.apply_central_impulse(direction)

	# rotate towards target
	root.rotation = direction.angle()

	distance_travelled += delta  # NOTE: this is probably dumb and not the right way to track distance.
