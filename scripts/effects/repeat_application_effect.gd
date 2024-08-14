## apply an array of effects a number of times, at given intervals
#@icon("")
class_name RepeatApplicationEffect
extends Effect


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
#@export_group("Details")


#endregion


#region VARS
# internals
var _current_iteration: int = 0
var _target: CombatActor
var _timer: Timer = Timer.new()
var _effects: Array[Effect] = []  ## the effects to apply each interval

# config
var interval: float = 1.0  ## how long between each application
var num_iterations: int = 1  ## how many iterations total
#endregion


#region FUNCS
func _ready() -> void:
	add_child(_timer)
	_timer.autostart = false
	_timer.wait_time = interval
	_timer.timeout.connect(_interval_passed)

func apply(target: CombatActor) -> void:
	if target is CombatActor:
		_target = target
	_timer.start()

func _interval_passed() -> void:
	for effect in _effects:
		if effect is Effect and is_instance_valid(_target):
			effect.apply(_target)

	_current_iteration += 1
	if _current_iteration >= num_iterations:
		_timer.stop()
		terminate()

func terminate() -> void:
	super()
	_timer.timeout.disconnect(_interval_passed)
	for effect in _effects:
		effect.terminate()

## add an effect to be applied each interval
func add_repeating_effect(effect: Effect) -> void:
	if effect is Effect:
		_effects.append(effect)


#endregion
