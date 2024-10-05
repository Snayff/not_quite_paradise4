@icon("res://components/functionals/hurtbox.png")
## Area where entity can be hurt.
class_name HurtboxComponent
extends Area2D


@export_group("Component Links")
## the actor that created the thing that used this hitbox.
@export var root: Actor


func _ready() -> void:
	assert(root is Actor, "Missing `root`.")
