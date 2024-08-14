## ABC for boon_banes
#@icon("")
class_name BoonBane
extends Node


#region SIGNALS
signal terminated(boon_bane: BoonBane)
signal activated
#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_category("Component Links")
# @export var
#
# @export_category("Details")  # feel free to rename category
#endregion


#region VARS
# internals
var _activations: int = 0  ## number of activations applied
var _duration_timer: Timer  ## only needed if duration_type is time
var _interval_timer: Timer  ## only needed if trigger is on_interval
# config
var host: CombatActor  ## the actor the boonbane is applied to
var trigger: Constants.TRIGGER  ## the thing that causes the boonbane to apply
var _effects: Array[Effect] = []  # NOTE: should we use an EffectChain instead?  ## the effects to be activated when the trigger happens
var duration_type: Constants.DURATION_TYPE  ## how the lifetime of the boonbane is determined
var duration: float  ## how long before being removed. only relevant if duration_type == time or applications, in which case it is seconds or num applications, respectively.
var interval_length: float  ## if trigger == on_interval then this dictates how long between each interval.
# TODO: add an internal cooldown to allow limiting how often we trigger
#endregion


#region FUNCS
func _ready() -> void:
	# check required values are set
	assert(not _effects.is_empty(), "BoonBane: no effects set.")
	if trigger == Constants.TRIGGER.on_interval and interval_length == 0:
		push_error("BoonBane: trigger is interval, but no interval_length set. Will never activate.")
	if (duration_type == Constants.DURATION_TYPE.time or duration_type == Constants.DURATION_TYPE.applications) and duration == 0:
		push_error("BoonBane: duration_type is time or application, but no duration set. Will immediately terminate.")
	# NOTE: can't check the enums as they default to a meaningful value

	# check logic errors
	assert(duration > interval_length, "BoonBane: duration is less than interval_length. Will never activate.")

	# setup timers
	if duration_type == Constants.DURATION_TYPE.time:
		_duration_timer = Timer.new()
		add_child(_duration_timer)
		_duration_timer.timeout.connect(terminate)
		_duration_timer.start(duration)
	if trigger == Constants.TRIGGER.on_interval:
		_interval_timer = Timer.new()
		add_child(_interval_timer)
		_interval_timer.timeout.connect(activate)
		_interval_timer.start(interval_length)

## apply the effect to the target. called on trigger. must be defined in subclass and super called.
##
## defaults to the host, if not other target given
# FIXME: how is this going to work? signals are set by BoonBaneContainer and therefore wont know which target we need. How would we do an effect
# 	where the attacker gets damage returned?
func activate(target: CombatActor = host) -> void:
	activated.emit()

	# check if we have applied max number of times
	if duration_type == Constants.DURATION_TYPE.applications:
		_activations += 1
		if _activations >= duration:
			terminate()

## finish and clean up
func terminate() -> void:
	terminated.emit(self)

	for effect in _effects:
		effect.terminate()

	queue_free()

func add_effect(effect: Effect) -> void:
	add_child(effect)
	_effects.append(effect)

func remove_effect(effect: Effect) -> void:
	if effect in _effects:
		_effects[effect].terminate()
		_effects.erase(effect)

#endregion
