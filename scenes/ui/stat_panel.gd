## a set of data pulled from the actors [StatsContainerComponent].
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
@export var _root: CombatActor
# @export_group("Details")
#endregion


#region VARS
var _labels: Array[Label] = []  ## hold all labels
#endregion


#region FUNCS
func _ready() -> void:
	# link to player#s target
	if name == "TargetStatPanel":
		_root.new_target.connect(_update_labels)
	# or link to player
	else:
		header.text = "Player Stats"
		_root.ready.connect(_update_labels.bind(_root))

	_labels.append(label)

func _update_labels(actor: CombatActor) -> void:
	if actor is not CombatActor:
		return

	# amend header
	if name == "TargetStatPanel":
		header.text = str(actor.name, " Stats")

	# add supplies
	var labels_added: int = 0
	if actor._supply_container is SupplyContainerComponent:
		var supplies: Array[SupplyComponent] = actor._supply_container.get_all_supplies()
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

	if actor.stats_container is not StatsContainerComponent:
		return

	# loop all stats
	var stats: Array[StatData] = actor.stats_container.get_all_stats()
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

func  _apply_supply_data_to_label(label_: Label, supply: SupplyComponent) -> Label:
	label_.text = str(Utility.get_enum_name(Constants.SUPPLY_TYPE, supply.type), ": ",  supply.value)
	return label_

func _apply_stat_data_to_label(label_: Label, stat: StatData) -> Label:
	label_.text = str(Utility.get_enum_name(Constants.STAT_TYPE, stat.type), ": ", stat.value)
	return label_








#endregion
