## a projectile that does not move on its own, but expected to be moved by a [ProjectileOrbiter]
@icon("res://assets/node_icons/projectile_orbital.png")
class_name ProjectileOrbital
extends ABCProjectile


#region SIGNALS
## emitted when resolved
signal hit_valid_target(hurtbox: HurtboxComponent)
#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS

#endregion


#region VARS

#endregion


#region FUNCS
func _ready() -> void:
	super._ready()

	# link hitbox signal to our on_hit
	_hitbox.hit_hurtbox.connect(_on_hit)

# start acting. must be manually triggered.
func activate() -> void:
	_set_hitbox_disabled(false)

	_sprite.play()

func _on_hit(hurtbox: HurtboxComponent) -> void:
	if !Utility.target_is_valid(_valid_hit_option, _hitbox.originator, hurtbox.root, _target_actor):
		return

	# update track of num bodies can hit
	_num_bodies_hit += 1

	# inform of hit
	hit_valid_target.emit(hurtbox)

	# if we've reached max hits, prevent further hits and self terminate
	if _num_bodies_hit >= _max_bodies_can_hit and _max_bodies_can_hit != -1:
		_set_hitbox_disabled(true)
		_set_collision_disabled(true)
		_terminate()





#endregion
