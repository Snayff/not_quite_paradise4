## denotes a stat and a portion of a stat to scale by.
##
## for use by effects
@icon("res://assets/node_icons/effect_stat_scaler.png")
class_name EffectStatScalerData
extends Resource


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
# @export_category("Component Links")
# @export var
#
@export_category("Details")
@export var stat: Constants.STAT_TYPE  ## stat to scale by the given amount
@export var scale_value: float  ## 0.5 is half of the stat, 1 is the same amount as the stat, 2 is double the stat.
#endregion


#region VARS

#endregion


#region FUNCS









#endregion
