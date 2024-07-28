## apply an array of effects a number of times, at given intervals
#@icon("")
class_name RepeatApplicationEffect
extends Node


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_category("Component Links")
# @export var
#
@export_category("Details")
@export var interval: float = 1.0  ## how long between each application
@export var num_iterations: int = 1  ## how many iterations total
@export var effects: Array[Effect] = []  ## the effects to apply each interval

#endregion


#region VARS
var _current_iteration: int = 0
var _target: CombatActor
var _timer: Timer = Timer.new()
#endregion


#region FUNCS
func _ready() -> void:
	_timer.autostart = false
	_timer.wait_time = interval
	_timer.timeout.connect(_interval_passed)

func apply(target: CombatActor) -> void:
	if target is CombatActor:
		_target = target
	_timer.start()  #FIXME: timer not added to scene tree

func _interval_passed() -> void:
	for effect in effects:
		if effect is Effect:
			effect.apply(_target)

	_current_iteration += 1
	if _current_iteration >= num_iterations:
		_timer.stop
		queue_free()







#endregion
