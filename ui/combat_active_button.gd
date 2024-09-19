## UI element displaying info about a [CombatActive]
## FIXME:  hacky as fuck. Temp only.
#@icon("")
class_name CombatActiveButton
extends TextureButton


#region SIGNALS

#endregion


#region ON READY (for direct children only)
@onready var _time_label: Label = $TimeLabel
@onready var _cooldown_progress_bar: TextureProgressBar = $CooldownProgressBar
@onready var _selected_border: PanelContainer = $SelectedBorder
#endregion


#region EXPORTS
@export_group("Component Links")
@export var _action_bar: ActionBar
#
# @export_group("Details")
#endregion


#region VARS
var combat_active: CombatActive
#endregion


#region FUNCS
func _ready() -> void:
	assert(_action_bar is ActionBar, "CombatActiveButton: No `action_bar` linked.")

	_action_bar.root_is_ready.connect(_post_ready)

func _post_ready() -> void:
	if combat_active is CombatActive:
		texture_normal = combat_active.icon

func _process(_delta: float) -> void:
	if combat_active is CombatActive:
		_time_label.text = "%3.1f" % combat_active.time_until_ready
		_cooldown_progress_bar.value = 100 * combat_active.percent_ready  # countdown from 100, so goes from filled to empty


func select() -> void:
	_selected_border.visible = true

func unselect() -> void:
	_selected_border.visible = false





#endregion
