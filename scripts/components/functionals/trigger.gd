## class desc
#@icon("")
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
	if _object_with_signal != null:
		if _object_with_signal.has_signal(_signal_name):
			var flag: int = 0
			if _is_oneshot:
				flag = ConnectFlags.CONNECT_ONE_SHOT
			_object_with_signal.connect(_signal_name, _trigger, flag)

## trigger objects method, based on [_object_to_trigger] and [_method_name_to_trigger]
func _trigger() -> void:
	if _object_to_trigger != null:
		if _object_to_trigger.has_method(_method_name_to_trigger):
			_object_to_trigger.call(_method_name_to_trigger)



#endregion
