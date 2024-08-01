## apply movement to the attached node
@icon("res://assets/node_icons/move.png")
class_name MovementComponent
extends Node


@export_category("Component Links")
@export var root: RigidBody2D


var target_actor: CombatActor  ## the actor being targeted. use when target updating required. preferred over target_position.
var target_position: Vector2  ## the position being targeted.
var direction: Vector2  ## direction towards target
var distance_travelled: float = 0  ## how far we have travelled
var speed: float


func _ready() -> void:
	# check for mandatory properties set in editor
	assert(root is Node2D, "Misssing `root`. ")

func _physics_process(delta: float) -> void:
	if is_instance_valid(target_actor):
		# move towards target
		_update_direction()
		var force = direction * speed
		root.force = force

		# rotate towards target
		root.rotation = direction.angle()

		distance_travelled += delta  # NOTE: this is probably dumb and not the right way to track distance.

func _update_direction() -> void:
	if target_actor is CombatActor:
		direction = target_actor.global_position - root.global_position
	elif  target_position != Vector2.ZERO:
		direction = target_position - root.global_position
	else:
		push_error("MovementComponent: No target to move towards.")
		direction = Vector2.ZERO
