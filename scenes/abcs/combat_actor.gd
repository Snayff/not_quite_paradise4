@icon("res://assets/node_icons/actor.png")
## entity that can move and fight in combat
class_name CombatActor
extends Node2D


signal target_changed(actor: CombatActor)

@onready var health: ResourceComponent = %Health
@onready var on_hit_flash: FlashComponent = %OnHitFlash


@export var target: CombatActor:  ## TODO: remove once proper targeting is in
	set(value):
		value = value
		target_changed.emit(target)

func _ready() -> void:
	if health is ResourceComponent:
		health.value_decreased.connect(on_hit_flash.activate)  # activate flash on hit
