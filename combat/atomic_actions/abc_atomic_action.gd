## ABC for AtomicActions. These are the most granular action in combat, e.g. dealing damage.
#@icon("")
class_name ABCAtomicAction
extends Node


#region SIGNALS
signal terminated(effect: ABCAtomicAction)
#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_group("Component Links")
# @export var
#
# @export_group("Details")  # feel free to rename category
#endregion


#region VARS
var _parent: Node  ## either [ABCEffectChain] or [ABCBoonBane]
var _source: Node  ## which entity created the effect, e.g. a [CombatActor]
#endregion


#region FUNCS
func _init(parent: Node, source: Node) -> void:
	assert(parent is ABCEffectChain or parent is ABCBoonBane, "Effect: parent isnt of expected type.")
	assert(source != null, "Effect: source is empty.")
	_parent = parent
	_source = source

## @virtual. apply the effect to the target
@warning_ignore("unused_parameter")  # virtual, so wont be used
func apply(target: CombatActor) -> void:
	push_error("Effect: `apply` called directly, but is virtual. Must be overriden by child." )

## @virtual. clean up any lingering traces of the effect, such as removing stat mods
@warning_ignore("unused_parameter")  # virtual, so wont be used
func reverse_application(target: CombatActor) -> void:
	push_error("Effect: `reverse_application` called directly, but is virtual. Must be overriden by child." )

## finish and clean up
func terminate() -> void:
	terminated.emit(self)
	queue_free()




#endregion
