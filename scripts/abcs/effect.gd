## class desc
#@icon("")
class_name Effect
extends Node


#region SIGNALS
signal terminated(effect: Effect)
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
var _parent: EffectChain
#endregion


#region FUNCS
func _init(parent: EffectChain) -> void:
	_parent = parent

## apply the effect to the target
func apply(target: CombatActor) -> void:
	pass

## finish and clean up
func terminate() -> void:
	terminated.emit(self)
	queue_free()




#endregion