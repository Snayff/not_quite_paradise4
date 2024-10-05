## a component that provides a way to interact with [Hurtbox]s.
@icon("res://components/functionals/hitbox.png")
class_name HitboxComponent
extends Area2D


# TODO: include the thing doing the hitting (and maybe originator?)
## when the hitbox hits a hurtbox
signal hit_hurtbox(hurtbox: HurtboxComponent)


## the actor that created the thing that used this hitbox
var originator: Actor

# TODO: add the hitter, i.e. the thing this is attached to that is doing the hitting
#		(does that replace originator, as you'd get the hitter's _caster or the like)
# TODO: add target validation here and remove from downstream

func _ready():
	# Connect on area entered to our hurtbox entered function
	area_entered.connect(_on_hurtbox_entered)

## this is a wrapper for [member area_entered]
func _on_hurtbox_entered(hurtbox: HurtboxComponent):
	# Make sure the area we are overlapping is a hurtbox
	if not hurtbox is HurtboxComponent:
		return

	# Signal out that we hit a hurtbox
	hit_hurtbox.emit(hurtbox)

## sets the collisions shape's disabled property to the value of is_disabled.
##
## This is a deferred call, so takes place on the next frame.
func set_disabled_status(is_disabled: bool) -> void:
	var shape: CollisionShape2D = get_node_or_null("CollisionShape2D")
	if shape is CollisionShape2D:
		shape.set_deferred("disabled", is_disabled)
