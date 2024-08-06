## pop up numbers over _root entity, a la damage numbers.
@icon("res://assets/node_icons/number.png")
class_name PopUpNumbers
extends Marker2D


#region SIGNALS

#endregion


#region ON READY

#endregion


#region EXPORTS
@export_category("Component Links")
@export var _root: Node2D
@export_category("Colours")
@export var _font_colour: Color = Color.WHITE
@export var _font_alt_colour: Color = Color.FIREBRICK
@export_category("Font")
@export var _font_size: int = 16
@export var _font: FontFile = FontFile.new()
@export_category("Outline")
@export var _outline_colour: Color = Color.BLACK
@export var _outline_size: int = 1
@export_category("Other")
@export var _duration: float = 0.25
#endregion


#region VARS


#endregion


#region FUNCS
func _ready() -> void:
	pass

func display_number(value: float, use_alt_settings: bool = false) -> void:
	var _label: Label = Label.new()
	add_child(_label)
	_label.global_position = global_position
	_label.text = str(value)
	_label.z_index = _root.z_index + 1  # NOTE: tut says set to 5

	_label.label_settings = LabelSettings.new()
	if use_alt_settings:
		_label.label_settings.font_color = _font_alt_colour
	else:
		_label.label_settings.font_color = _font_colour
	_label.label_settings.font_size = _font_size
	_label.label_settings.outline_color = _outline_colour
	_label.label_settings.outline_size = _outline_size
	if _font is FontFile:
		_label.label_settings.font = _font

	# when size updated, offest to centre
	await  _label.resized
	_label.pivot_offset = Vector2(_label.size / 2)  # FIXME: this doesnt seem to be working as still seems offset to the right

	# tween position up and down
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	# TODO: tween in a random direction, up and away
	tween.tween_property(_label, "position:y", _label.position.y - 24, _duration / 2).set_ease(Tween.EASE_OUT)
	tween.tween_property(_label, "position:y", _label.position.y, _duration / 2).set_ease(Tween.EASE_IN).set_delay(_duration / 2)

	# tween scale to zero
	tween.tween_property(_label, "scale", Vector2.ZERO, _duration / 2).set_ease(Tween.EASE_OUT).set_delay(_duration)

	# clear when tween finished
	await  tween.finished
	_label.queue_free()




#endregion
