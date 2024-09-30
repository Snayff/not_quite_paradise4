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
@export var type: Constants.BOON_BANE_TYPE
@warning_ignore("unused_variable")  # (will be) used by other classes
## icon to show identify the boon_bane
@export var icon: Texture2D
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
## the scene to create periodically, to show still active
@export var _reminder_animation_scene: PackedScene
## how often to replay the _reminder_animation_scene.
## if remindering too fast it will overlap plays.
@export var _reminder_animation_interval: float = Constants.DEFAULT_BOON_BANE_REMINDER_ANIMATION_INTERVAL
## the max number of stacks that can exist
## if == 1 then functionally unique.
@export var _max_stacks: int = 1
#endregion


#region VARS
## number of stacks on the boon bane
var _stacks: int = 0
## who is the original source of the effect
var _source: Actor
## how long to last before expiry
## only used if duration_type is time
var _duration_timer: Timer
## how long between each application
## only used if trigger is on_interval
var _interval_timer: Timer
## how long between creations of the _reminder_animation_scene
## only used if _reminder_animation_scene is not null
var _reminder_animation_timer: Timer
## the actor the boonbane is applied to
var _host: Actor
# NOTE: should we use an ABCEffectChain instead?
## the effects to be activated when the trigger happens
var _effects: Array[ABCAtomicAction] = []
## the scene from _reminder_animation_scene, held as an Atomic Action
var _reminder_animation_visual_effect: ABCAtomicAction
## if this is the first activation, or not
var _is_first_activation: bool = true
# TODO: add an internal cooldown to allow limiting how often we trigger
#endregion


#region FUNCS

##########################
####### LIFECYCLE ######
######################

func _init(host: Actor, source: Actor) -> void:
	_host = host
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
		_duration_type == Constants.DURATION_TYPE.stacks) and _duration == 0:
		assert(
			is_zero_approx(_duration),
			str(
				"BoonBane: duration_type is time or application, but no duration set.",
				"Will immediately terminate."
			)
		)

	_setup_timers()

## init and configure required timers.
##
## assumes _ready, and therefore _configure_behaviour, have been run.
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

	if _reminder_animation_scene is PackedScene:
		_reminder_animation_timer = Timer.new()
		add_child(_reminder_animation_timer)
		# start after first activation, in activate()

## apply the effect to the target. called on trigger. must be defined in subclass and super called.
##
## defaults to the host, if not other target given
# FIXME: how is this going to work? signals are set by BoonBaneContainer and therefore wont know which target we need. How would we do an effect
# 	where the attacker gets damage returned?
func activate(target: Actor = _host) -> void:
	# inform listeners we activated boon bane
	activated.emit()

	# apply effects
	for effect in _effects:

		# if there's a multiplier prop then set it to the number of stacks we have
		if "multiplier" in effect:
			effect.multiplier = max(_stacks, 1)

		effect.apply(target)

	# start the reminder animation on the first activation
	if _is_first_activation and _reminder_animation_scene is PackedScene:
		if _reminder_animation_visual_effect is not AtomicActionSpawnScene:
			push_warning(
				"ABCBoonBane: `_reminder_animation_visual_effect` not populated in ",
				f_name,
				". Did you call `_create_application_animations` in `_configure_behaviour`?"
				)
		else:
			_reminder_animation_timer.timeout.connect(
				_reminder_animation_visual_effect.apply.bind(target)
			)
			_reminder_animation_timer.start(_reminder_animation_interval)

	# if lifetime is determined by applications, reduce num stacks
	if _duration_type == Constants.DURATION_TYPE.stacks:
		_stacks -= 1
		if _stacks <= 0:
			terminate()

	_is_first_activation = false

## finish and clean up. reverse application of any lingering affects.
func terminate() -> void:
	terminated.emit(self)

	for effect in _effects:
		if effect is AtomicActionApplyStatMod:
			effect.reverse_application(_host)
		effect.terminate()

	queue_free()

##########################
####### PUBLIC ##########
########################

## add stacks, up to _max_stacks. reset duration identifiers, such as duration timer
func add_stacks_and_refresh_duration(num_stacks) -> void:
	_stacks = clampi(_stacks + num_stacks, 0, _max_stacks)

	# reset lifetime/duration
	if _duration_type == Constants.DURATION_TYPE.time:
		# if timer is active, reset it
		if _duration_timer is Timer:
			_duration_timer.start(_duration)

##########################
####### PRIVATE #########
########################

func _add_effect(effect: ABCAtomicAction) -> void:
	add_child(effect)
	_effects.append(effect)

func _remove_effect(effect: ABCAtomicAction) -> void:
	if effect in _effects:
		_effects[effect].terminate()
		_effects.erase(effect)

## @virtual where the effects are created and defined.
func _configure_behaviour() -> void:
	push_error(
		"BoonBane: `_configure_behaviour` called directly, but is virtual.",
		"Must be overriden by child."
	)

## create required animations and gets them ready for use.
##
## specifically:
## 1. create the scene in _application_animation_scene and add it as an	[AtomicActionSpawnScene] to
## _effects
## 2. create the scene in _reminder_animation_scene and add to _reminder_animation_visual_effect
func _create_application_animations() -> void:
	if _application_animation_scene is PackedScene:
		var animation: AtomicActionSpawnScene = AtomicActionSpawnScene.new(self, _source)
		animation.scene = _application_animation_scene
		_add_effect(animation)

	if _reminder_animation_scene is PackedScene:
		var animation: AtomicActionSpawnScene = AtomicActionSpawnScene.new(self, _source)
		animation.scene = _reminder_animation_scene
		_reminder_animation_visual_effect = animation

#endregion
