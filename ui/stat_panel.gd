## a set of data pulled from the actors [StatsContainer].
## WARNING: Hacky as fuck.
#@icon("")
class_name StatPanel
extends VBoxContainer


#region SIGNALS

#endregion


#region ON READY (for direct children only)
@onready var label: Label = $Label
@onready var header: Label = $Header

#endregion


#region EXPORTS
@export_group("Component Links")
@export var _root: Actor
# @export_group("Details")
#endregion


#region VARS
var _labels: Array[Label] = []  ## hold all labels
var _target: Actor
#endregion


#region FUNCS
func _ready() -> void:
	# link to player#s target
	if name == "TargetStatPanel":
		_root.new_target.connect(set_target)
	# or link to player
	else:
		header.text = "Player Stats"
		_root.ready.connect(set_target.bind(_root))

	_labels.append(label)

func _process(_delta: float) -> void:
	if _target is Actor:
		_update_labels()

func set_target(actor: Actor) -> void:
	_target = actor

func _update_labels() -> void:
	var template_label = _labels[0].duplicate()
	var label_size = _labels.size()
	for i in label_size:
		_labels[i].queue_free()
		_labels[i] = null

	label = template_label
	_labels = [template_label]

	# amend header
	if name == "TargetStatPanel":
		header.text = str(_target.name, " Stats")

	# add supplies
	var labels_added: int = 0
	if _target._supply_container is SupplyContainer:
		var supplies: Array[SupplyComponent] = _target._supply_container.get_all_supplies()
		for i in range(supplies.size()):
			var supply = supplies[i]

			# check if we need a new label. if we do, add one, based on initial label.
			# either way, add stat data into the label.
			if _labels.size() <= i:
				var new_label: Label = label.duplicate()
				add_child(new_label)
				_labels.append(_apply_supply_data_to_label(new_label, supply))
			else:
				_labels[i] = _apply_supply_data_to_label(_labels[i], supply)

			labels_added += 1

	if _target.stats_container is StatsContainer:
		# loop all stats
		var stats: Array[StatData] = _target.stats_container.get_all_stats()
		for i in range(stats.size()):
			var stat = stats[i]

			# check if we need a new label. if we do, add one, based on initial label.
			# either way, add stat data into the label.
			if _labels.size() <= i + labels_added:
				var new_label: Label = label.duplicate()
				add_child(new_label)
				_labels.append(_apply_stat_data_to_label(new_label, stat))
			else:
				_labels[i + labels_added] = _apply_stat_data_to_label(_labels[i + labels_added], stat)

			labels_added += 1


	if _target.boons_banes is BoonBaneContainer:
		# loop all boon_banes
		var boon_banes: Array[ABCBoonBane] = _target.boons_banes.get_all_boon_banes()
		for i in range(boon_banes.size()):
			var boon_bane = boon_banes[i]

			# check if we need a new label. if we do, add one, based on initial label.
			# either way, add stat data into the label.
			if _labels.size() <= i + labels_added:
				var new_label: Label = label.duplicate()
				add_child(new_label)
				_labels.append(_apply_boonbane_data_to_label(new_label, boon_bane))
			else:
				_labels[i + labels_added] = _apply_boonbane_data_to_label(_labels[i + labels_added], boon_bane)

			labels_added += 1

func  _apply_supply_data_to_label(label_: Label, supply: SupplyComponent) -> Label:
	label_.text = str(Utility.get_enum_name(Constants.SUPPLY_TYPE, supply.type), ": ",  supply.value)
	return label_

func _apply_stat_data_to_label(label_: Label, stat: StatData) -> Label:
	label_.text = str(Utility.get_enum_name(Constants.STAT_TYPE, stat.type), ": ", stat.value)
	return label_

func _apply_boonbane_data_to_label(label_: Label, boonbane: ABCBoonBane) -> Label:
	label_.text = boonbane.f_name
	return label_






#endregion
