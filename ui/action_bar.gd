## UI container to hold and align [CombatActiveButton]s.
#@icon("")
class_name ActionBar
extends HBoxContainer


#region SIGNALS
signal root_is_ready  ## tell children that root is ready, so can run post_ready()
#endregion


#region ON READY (for direct children only)

#endregion


#region EXPORTS
@export_group("Component Links")
@export var _root: Actor
# @export_group("Details")
#endregion


#region VARS
var _buttons: Array[CombatActiveButton] = []
var _currently_selected_index: int = 0
#endregion


#region FUNCS
func _ready() -> void:
    if _root is Actor:
        _root.ready.connect(_post_ready)

func _post_ready() -> void:
    _load_buttons()
    _assign_actives_to_buttons()

    _root.combat_active_container.new_active_selected.connect(_select_new_button)

    root_is_ready.emit()

## load appropriate child buttons. selects first in array.
func _load_buttons() -> void:
    for child in get_children():
        if child is CombatActiveButton:
            _buttons.append(child)
            child.unselect()  # make sure unselect proces followed, so all at start state

    _buttons[_currently_selected_index].select()

## link actives to buttons
func _assign_actives_to_buttons() -> void:
    var actives = _root.combat_active_container.get_all_actives()
    var i = 0
    for button in _buttons:
        button.combat_active = actives[i]
        i += 1
        if i >= actives.size():
            break

## select a new button. active given must be the one linked to the button
func _select_new_button(active: CombatActive) -> void:
    _buttons[_currently_selected_index].unselect()

    for i in _buttons.size():
        if _buttons[i].combat_active == active:
            _buttons[i].select()
            _currently_selected_index = i



#endregion
