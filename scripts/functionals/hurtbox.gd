## Area where entity can be hurt.
class_name HurtboxComponent
extends Area2D

@export var target_resource: ResourceComponent  ## the resource damaged when this Hurtbox is hit # TODO: move to projectile

## this hurtbox is hit by a hitbox
signal hurt(hitbox)

var is_invincible = false :
	# disable and enable collision shapes on the hurtbox when is_invincible is changed.
	set(value):
		is_invincible = value
		# Disable any collisions shapes on this hurtbox when it is invincible
		# And reenable them when it isn't invincible
		for child in get_children():
			if not child is CollisionShape2D and not child is CollisionPolygon2D: continue
			# Use call deferred to make sure this doesn't happen in the middle of the
			# physics process
			child.set_deferred("disabled", is_invincible)


#func _ready() -> void:
	## Connect the hurt signal to an anonymous function
	## that removes health equal to the damage from the hitbox
	#hurt.connect(func(hitbox_component: HitboxComponent):
		#target_resource.decrease(hitbox_component.damage)
	#)
