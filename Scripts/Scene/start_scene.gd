extends Node2D

class_name StartScene

var screen_transition : ScreenTransition

func _enter_tree() -> void:
	hide()

func _ready():
	$DifficultyPanel/EasyButton.connect("pressed", on_start_easy_pressed)
	$DifficultyPanel/NormalButton.connect("pressed", on_start_normal_pressed)
	$DifficultyPanel/HardButton.connect("pressed", on_start_hard_pressed)
	$DifficultyPanel/VeryHardButton.connect("pressed", on_start_veryhard_pressed)
	
	screen_transition = $ScreenTransition
	
	$MusicSlider.value = AudioManager.GetBusVolume("Music")	
	$EffectsSlider.value = AudioManager.GetBusVolume("Effects")	

	$MusicSlider.connect("value_changed", on_music_volume_changed)
	$EffectsSlider.connect("value_changed", on_effects_volume_changed)
	
	# The transition is done by setting a room name
	screen_transition.FadeIn()
	show()

func on_start_easy_pressed():
	Globals.difficulty = Constants.DIFFICULTY.EASY
	start()
func on_start_normal_pressed():
	Globals.difficulty = Constants.DIFFICULTY.NORMAL
	start()
func on_start_hard_pressed():
	Globals.difficulty = Constants.DIFFICULTY.HARD
	start()
func on_start_veryhard_pressed():
	Globals.difficulty = Constants.DIFFICULTY.VERY_HARD
	start()
func start():
	_transition_to("res://game_scene.tscn")


func _transition_to(scene):
	screen_transition.FadeOut()
	await screen_transition.Animations.animation_finished
	get_tree().change_scene_to_file(scene)


func on_music_volume_changed(v : float) -> void:
	AudioManager.SetBusVolume("Music", v)
func on_effects_volume_changed(v : float) -> void:
	AudioManager.SetBusVolume("Effects", v)	
