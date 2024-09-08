## an aura is an area of effect that can follow a target's position and loops for a duration. terminates at end of lifetime_timer.
@icon("res://assets/node_icons/aura.png")
class_name Aura
extends AreaOfEffect


#region SIGNALS
@onready var _tick_rate_timer: Timer = %TickRateTimer
@onready var _lifetime_timer: Timer = %LifetimeTimer

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
# @export_group("Details")
#endregion


#region VARS
var _target: CombatActor
var _lifetime: float  ## how long the aura lasts before expiring.
#endregion


#region FUNCS
func setup(
	new_position: Vector2,
	team: Constants.TEAM,
	valid_effect_option: Constants.TARGET_OPTION,
	size: float = -1,
	lifetime: float = -1,
	) -> void:
	assert(lifetime > 0, "Aura: lifetime cannot be <= 0, otherwise will never exist.")

	if animation_looped.is_connected(_cleanup):
		animation_looped.disconnect(_cleanup)
	if animation_finished.is_connected(_cleanup):
		animation_finished.disconnect(_cleanup)
	animation_looped.connect(_restart)
	animation_finished.connect(_restart)

	_lifetime_timer.timeout.connect(_cleanup)
	_tick_rate_timer.timeout.connect(_start)

	_lifetime = lifetime
	super.setup(new_position, team, valid_effect_option, size)
	_lifetime_timer.start(_lifetime)

func _process(_delta: float) -> void:
	if _target is CombatActor:
		global_position = _target.global_position

## attach the aoe to the given actor. will cause the aoe to follow the movement of the target.
func attach_to_target(actor: CombatActor) -> void:
	_target = actor

## restart the process, i.e. loop, after the delay
func _restart() -> void:
	stop()
	visible = false

	# trigger timer, which will trigger restart when done
	_tick_rate_timer.start(Constants.AURA_TICK_RATE)

	# reset flags
	_has_signalled_out_hit_valid_targets = false
	_has_been_enabled = false









#endregion
