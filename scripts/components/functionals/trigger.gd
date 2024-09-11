## Simple connector between a signal in 1 node and a method in another.
##
## Does not handle methods that expect arguments, unless the signal and the method
## match exactly.
@icon("res://assets/node_icons/trigger.png")
class_name ComponentTrigger
extends Node


#region SIGNALS

#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
@export_group("Inbound Signal")
@export var _object_with_signal: Node
@export var _signal_name: String
@export var _num_signal_args: int = 0  ## the number of arguments to unbind
@export_group("Outbound Trigger")
@export var _object_to_trigger: Node2D
## string name of the method to trigger on the specified object. does not work with methods
## that require arguments
@export var _method_name_to_trigger: String = ""
@export_group("Details")
@export var _is_oneshot: bool
#
# @export_group("Details")
#endregion


#region VARS

#endregion


#region FUNCS
func _ready() -> void:
	if _object_with_signal == null:
		return
	if !_object_with_signal.has_signal(_signal_name):
		return

	# get flag for oneshot
	var flag: int = 0
	if _is_oneshot:
		flag = ConnectFlags.CONNECT_ONE_SHOT

	# unbind args and connect signal
	var trigger_callable: Callable
	if _num_signal_args == 0:
		trigger_callable = _trigger
	else:
		trigger_callable = _trigger.unbind(_num_signal_args)

	_object_with_signal.connect(_signal_name, trigger_callable, flag)


## trigger objects method, based on [_object_to_trigger] and [_method_name_to_trigger]
func _trigger() -> void:
	if _object_to_trigger != null:
		if _object_to_trigger.has_method(_method_name_to_trigger):
			_object_to_trigger.call_deferred(_method_name_to_trigger)



#endregion
