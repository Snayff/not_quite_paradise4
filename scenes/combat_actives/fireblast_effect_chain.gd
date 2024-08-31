## the series of effects for the fireblast skill
class_name FireblastEffectChain
extends EffectChain


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
@export_group("On Hit")
@export var _hit_damage: int = 1
@export_group("AoE")
@export var _aoe_damage: int = 1

#endregion


#region VARS

#endregion


#region FUNCS
func on_hit(hurtbox: HurtboxComponent) -> void:
	var actor_hit: CombatActor = hurtbox.root

	# initial damage
	var effect = DealDamageEffect.new(self, _caster)
	_register_effect(effect)
	effect.base_damage = _hit_damage
	effect.apply(actor_hit)

	# aoe
	var _aoe: AreaOfEffect = _aoe_scene.instantiate()
	# need to defer adding the _aoe as a child
	# as cannot add new Area2Ds to a scene during a call of another Area2D's on_area_entered()
	await call_deferred("add_child", _aoe)
	_aoe.setup(hurtbox.global_position, _allegiance.team, _valid_effect_option)
	_aoe.hit_valid_targets.connect(_aoe_hit)

func _aoe_hit(bodies: Array[PhysicsBody2D]) -> void:
	# create damage effect
	var effect = DealDamageEffect.new(self, _caster)
	_register_effect(effect)
	effect.base_damage = _aoe_damage
	effect.is_one_shot = false

# TODO:
#  need to debug this, as:
#	 firing loads of damage, not just once,
#	 not sure if hitting multiple people
#	there is a delay after hitting before applying (which might jsut be settings)
# add asserts to setup funcs

	for body in bodies:

		# apply damage
		effect.apply(body)

		# apply boon_bane
		if not body.boons_banes is BoonsBanesContainerComponent:
			# no boon bane container to apply a boon bane to
			continue
		var burn = Burn.new(_caster)
		body.boons_banes.add_boon_bane(burn)

	effect.terminate()

#endregion
