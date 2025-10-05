extends Node2D

class_name TutorialController

@onready var  know_your_card : KnowYourCard = $"Know your card"

func _ready() -> void:
	hide_all()
	
	$Tutorial1/CloseButton.connect("pressed", on_tutorial1_close_pressed)

func start_tutorial() -> void:
	hide_all()
	$Tutorial1.show()

func show_card_reference() -> void:
	hide_all()
	know_your_card.show()
	
func hide_all() -> void:
	$Tutorial1.hide()
	know_your_card.hide()

func on_tutorial1_close_pressed() -> void:
	$Tutorial1.hide()
	show_card_reference()
