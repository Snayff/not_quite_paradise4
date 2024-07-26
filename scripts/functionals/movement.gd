@icon("res://assets/node_icons/move.png")
## apply movement to the actor
class_name MovementComponent
extends Node

@export var rigid_body_2d: RigidBody2D
@export var root: Node2D


var target_actor: CombatActor  ## the actor being targeted. use when target updating required. preferred over target_position.
var target_position: Vector2  ## the position being targeted.
var direction: Vector2  ## direction towards target
	#set(value):
		#push_warning("Can't set movement direction directly, need to set `target_position` or `target_actor`.")
		#return
	#get:
		#_update_direction()
		#return _direction
#var _direction: Vector2 = Vector2.ZERO
var distance_travelled: float = 0  ## how far we have travelled


func _ready() -> void:
	# check for mandatory properties set in editor
	assert(root is Node2D, "Misssing `root`. ")
	assert(rigid_body_2d is RigidBody2D, "Misssing `rigid_body_2d`. ")


func _physics_process(delta: float) -> void:
	# move towards target
	_update_direction()
	var force = direction * 10000
	print(force)
	rigid_body_2d.apply_central_impulse(force)

	# rotate towards target
	root.rotation = direction.angle()

	distance_travelled += delta  # NOTE: this is probably dumb and not the right way to track distance.

func _update_direction() -> void:
	if target_actor is CombatActor:
		var start = root.global_position
		var end = target_actor.global_position
		direction = target_actor.global_position - root.global_position
	elif  target_position != Vector2.ZERO:
		direction = root.global_position - target_position
	else:
		push_error("No target to move towards.")
		direction = Vector2.ZERO
