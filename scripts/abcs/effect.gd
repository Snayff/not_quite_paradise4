## ABC for Effect
#@icon("")
class_name Effect
extends Node


#region SIGNALS
signal terminated(effect: Effect)
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
var _parent: Node  ## either [EffectChain] or [BoonBane]
var _source: Node  ## which entity created the effect, e.g. a [CombatActor]
#endregion


#region FUNCS
func _init(parent: Node, source: Node) -> void:
	assert(parent is EffectChain or parent is BoonBane, "Effect: parent isnt of expected type.")
	assert(source != null, "Effect: source is empty.")
	_parent = parent
	_source = source

## @virtual. apply the effect to the target
func apply(target: CombatActor) -> void:
	pass

## finish and clean up
func terminate() -> void:
	terminated.emit(self)
	queue_free()




#endregion
