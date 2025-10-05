extends Node2D

class_name KnowYourCard


func _ready():
	#$Card.initialize_tutorial(card_descriptor)
	$CloseButton.connect("pressed", on_close_pressed)

func on_close_pressed() -> void:
	hide()
	Globals.scene.UnpauseForTutorialPopup()
