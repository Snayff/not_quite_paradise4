## entity that can move and fight in combat
class_name CombatActor
extends Node2D


@onready var health: ResourceComponent = %Health
@onready var on_hit_flash: FlashComponent = %OnHitFlash


@export var target: CombatActor  ## TODO: remove once proper targeting is in

func _ready() -> void:
	if health is ResourceComponent:
		health.value_decreased.connect(on_hit_flash.activate)  # activate flash on hit
