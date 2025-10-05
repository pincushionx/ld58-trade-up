extends Node2D

class_name Scene

signal paused
signal unpaused

var player : Player
var deck_display : DeckDisplay
var board : Board
var tutorial : TutorialController

var win_popup : Control
var lose_popup : Control
var trade_button : Button
var discard_button : Button

var max_heat : int

var screen_transition : ScreenTransition

var playMode : Constants.PlayMode = Constants.PlayMode.PLAY

@export var show_tutorial : bool = false

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	Globals.scene = self

	player = $Player
	deck_display = $DeckDisplay

	board = $Board
	tutorial = $Tutorial
	
	win_popup = $WinPopup
	win_popup.hide()

	lose_popup = $LosePopup
	lose_popup.hide()
	
	screen_transition = $ScreenTransition
	
	trade_button = $TradeButton
	trade_button.connect("pressed", on_trade_button_pressed)
	
	discard_button = $DiscardButton
	discard_button.connect("pressed", on_discard_button_pressed)

	$Volume/MusicSlider.value = AudioManager.GetBusVolume("Music")	
	$Volume/EffectsSlider.value = AudioManager.GetBusVolume("Effects")	

	$Volume/MusicSlider.connect("value_changed", on_music_volume_changed)
	$Volume/EffectsSlider.connect("value_changed", on_effects_volume_changed)

	$CardReferenceButton.connect("pressed", show_card_reference)
	$TutorialButton.connect("pressed", start_tutorial)
	
	$WinPopup/Control/RestartButton.connect("pressed", on_restart_pressed)
	$LosePopup/Control/RestartButton.connect("pressed", on_restart_pressed)


	hide()
	
	
	

func _ready():
	# The transition is done by setting a room name
	screen_transition.FadeIn()
	show()

	if show_tutorial:
		tutorial.start_tutorial()

	AudioManager.PlayMusic("Music")


func show_card_reference() -> void:
	PauseForTutorialPopup()
	tutorial.show_card_reference()

func start_tutorial() -> void:
	PauseForTutorialPopup()
	tutorial.start_tutorial()

func on_trade_button_pressed():
	board.trade()

func on_discard_button_pressed():
	board.show_discard_popup()

func IsGameplayPaused():
	return Util.InMask(playMode, Constants.PlayMode.GAMEPLAY_PAUSED)

func IsPausedForDiscardPopup():
	return Util.InMask(playMode, Constants.PlayMode.DISCARD_POPUP)

func IsPausedForTutorialPopup():
	return Util.InMask(playMode, Constants.PlayMode.TUTORIAL_POPUP)
	
func IsPausedForPopup():
	return Util.InMask(playMode, Constants.PlayMode.MODAL_POPUP)

func IsPausedForEndPopup():
	return Util.InMask(playMode, Constants.PlayMode.WIN_POPUP) || Util.InMask(playMode, Constants.PlayMode.LOSE_POPUP)

func PauseForDiscardPopup():
	@warning_ignore("int_as_enum_without_cast")
	playMode |= Constants.PlayMode.DISCARD_POPUP

func UnpauseForDiscardPopup():
	@warning_ignore("int_as_enum_without_cast")
	playMode &= ~Constants.PlayMode.DISCARD_POPUP

func PauseForTutorialPopup():
	@warning_ignore("int_as_enum_without_cast")
	playMode |= Constants.PlayMode.TUTORIAL_POPUP

func UnpauseForTutorialPopup():
	@warning_ignore("int_as_enum_without_cast")
	playMode &= ~Constants.PlayMode.TUTORIAL_POPUP

func Pause():
	@warning_ignore("int_as_enum_without_cast")
	playMode |= Constants.PlayMode.PAUSED_MENU
	paused.emit()

func Unpause():
	@warning_ignore("int_as_enum_without_cast")
	playMode &= ~Constants.PlayMode.PAUSED_MENU
	unpaused.emit()

func win_level() -> void:

	
	Globals.is_win_condition = true

	playMode = Constants.PlayMode.WIN_POPUP
	win_popup.show()

func lose_level() -> void:
	Globals.is_lose_condition = true
	playMode = Constants.PlayMode.LOSE_POPUP
	lose_popup.show()

func on_restart_pressed() -> void:
	_transition_to("res://start_scene.tscn")

func reset_current_scene() -> void:
	screen_transition.FadeOut()
	await screen_transition.Animations.animation_finished
	get_tree().reload_current_scene()

func _transition_to(scene):
	screen_transition.FadeOut()
	await screen_transition.Animations.animation_finished
	get_tree().change_scene_to_file(scene)


func on_music_volume_changed(v : float) -> void:
	AudioManager.SetBusVolume("Music", v)
func on_effects_volume_changed(v : float) -> void:
	AudioManager.SetBusVolume("Effects", v)	
