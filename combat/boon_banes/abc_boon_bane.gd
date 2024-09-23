## ABC for boon_banes
@icon("res://shared_assets/node_icons/abc.png")
class_name ABCBoonBane
extends Node


#region SIGNALS
signal terminated(boon_bane: ABCBoonBane)
signal activated
#endregion


#region ON READY

#endregion


#region EXPORTS
@export_group("Definition")
## the friendly name
@export var f_name: String = "placeholder name"
# NOTE: Not yet used
## icon to show identify the boon_bane
@export var _icon: Texture2D
@export_group("Application")
## the thing that causes the boonbane to apply
@export var trigger: Constants.TRIGGER
## how the lifetime of the boonbane is determined
@export var _duration_type: Constants.DURATION_TYPE
## how long before being removed. only relevant if duration_type == time or applications,
## in which case it is seconds or num applications, respectively.
@export var _duration: float
## if trigger == on_interval then this dictates how long between each interval.
@export var _interval_length: float
@warning_ignore("unused_private_class_variable")  # used in children
## the scene to create when we are applied
@export var _application_animation_scene: PackedScene
## whether multiple of the same boonbanes can be applied
@export var is_unique: bool = true
#endregion


#region VARS
# internals
## number of activations applied
var _activations: int = 0
## who is the original source of the effect
var _source: CombatActor
# config
## how long to last before expiry
## only used if duration_type is time
var _duration_timer: Timer
## how long between each application
## only needed if trigger is on_interval
var _interval_timer: Timer
## the actor the boonbane is applied to
var host: CombatActor
# NOTE: should we use an ABCEffectChain instead?
## the effects to be activated when the trigger happens
var _effects: Array[ABCAtomicAction] = []
# TODO: add an internal cooldown to allow limiting how often we trigger
#endregion


#region FUNCS
func _init(source: CombatActor) -> void:
	_source = source

func _ready() -> void:
	_configure_behaviour()  # must call first, before validity checks

	# check required values are set
	# NOTE: can't check the enums as they default to a meaningful value
	assert(not _effects.is_empty(), "BoonBane: no effects set.")
	if trigger == Constants.TRIGGER.on_interval:
		assert(
			_interval_length != 0,
			str(
				"BoonBane: trigger is interval, but no interval_length set." ,
				"Will never activate."
			)
		)
		assert(
			_duration > _interval_length,
			"BoonBane: duration is less than interval_length. Will never activate."
		)

	if (_duration_type == Constants.DURATION_TYPE.time or \
		_duration_type == Constants.DURATION_TYPE.applications) and _duration == 0:
		assert(
			is_zero_approx(_duration),
			str(
				"BoonBane: duration_type is time or application, but no duration set.",
				"Will immediately terminate."
			)
		)

	# if we need to apply immediately, wait a frame then do so
	if trigger == Constants.TRIGGER.on_application:
		Utility.call_next_frame(activate)

	_setup_timers()

## @virtual where the effects are created and defined.
func _configure_behaviour() -> void:
	push_error(
		"BoonBane: `_configure_behaviour` called directly, but is virtual.",
		"Must be overriden by child."
	)

## init and configure required timers
func _setup_timers() -> void:
	if _duration_type == Constants.DURATION_TYPE.time:
		_duration_timer = Timer.new()
		add_child(_duration_timer)
		_duration_timer.timeout.connect(terminate)
		_duration_timer.start(_duration)

	if trigger == Constants.TRIGGER.on_interval:
		_interval_timer = Timer.new()
		add_child(_interval_timer)
		_interval_timer.timeout.connect(activate)
		_interval_timer.start(_interval_length)



## apply the effect to the target. called on trigger. must be defined in subclass and super called.
##
## defaults to the host, if not other target given
# FIXME: how is this going to work? signals are set by BoonBaneContainer and therefore wont know which target we need. How would we do an effect
# 	where the attacker gets damage returned?
func activate(target: CombatActor = host) -> void:
	activated.emit()

	for effect in _effects:
		effect.apply(target)

	# check if we have applied max number of times
	if _duration_type == Constants.DURATION_TYPE.applications:
		_activations += 1
		if _activations >= _duration:
			terminate()

## finish and clean up. reverse application of any lingering affects.
func terminate() -> void:
	terminated.emit(self)

	for effect in _effects:
		if effect is AtomicActionApplyStatMod:
			effect.reverse_application(host)
		effect.terminate()

	queue_free()

func _add_effect(effect: ABCAtomicAction) -> void:
	add_child(effect)
	_effects.append(effect)

func _remove_effect(effect: ABCAtomicAction) -> void:
	if effect in _effects:
		_effects[effect].terminate()
		_effects.erase(effect)

## create the scene in _application_animation_scene and add it as an effect
func _create_application_visual_effects() -> void:
	if _application_animation_scene is not PackedScene:
		return

	var visual_effect: AtomicActionSpawnScene = AtomicActionSpawnScene.new(self, _source)
	visual_effect.scene = _application_animation_scene
	_add_effect(visual_effect)

#endregion
