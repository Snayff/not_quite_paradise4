## amend a resource by adding, subtracting or multiplying the value
##
## these are direct manipulations, no resistances are taken into consideration.
#@icon("")
class_name AlterResource
extends Effect


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_category("Component Links")
# @export var
#
@export_category("Details")
@export var resource_name: String
@export var alteration_amount: int  ## the amount to add or subtract from the resource
@export var multiplier: float  ## the amount to multiply the resource by

#endregion


#region VARS

#endregion


#region FUNCS

func apply(target: CombatActor) -> void:
	var resource = target.get_node_or_null(resource_name.capitalize())
	if resource is ResourceComponent:

		# apply addition/subtraction first
		if alteration_amount > 0:
			resource.increase(alteration_amount)
		else:
			resource.decrease(alteration_amount)

		# apply multiplier
		resource.set_value(resource.value * multiplier)

#endregion
