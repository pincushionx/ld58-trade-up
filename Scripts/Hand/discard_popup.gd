extends Hand

class_name DiscardPopup

signal discarded
signal cancelled

var ok_button : Button
var cancel_button : Button

func _on_ready() -> void:
	ok_button = $OkButton
	cancel_button = $CancelButton
	
	ok_button.connect("pressed", _on_ok_pressed)
	cancel_button.connect("pressed", _on_cancel_pressed)

## Override
func _on_place_card(_slot : CardSlot, card : Card) -> void:
	card.z_index = 25

## Override
func _on_slot_card_removed(_slot : CardSlot, card : Card) -> void:
	card.reset_z_index()

func _on_ok_pressed() -> void:
	
	# TODO Animate
	var is_card_discarded : bool = false
	for slot in card_slots:
		if !slot.is_empty():
			for card in slot.cards:
				is_card_discarded = true
				Globals.scene.board.discard_pile.discard(card)
	
	
	if !is_card_discarded:
		# Raise a message
		pass
	else:
		discarded.emit()
	
func _on_cancel_pressed() -> void:
	for slot in card_slots:
		if !slot.is_empty():
			for card in slot.cards:
				Globals.scene.board.player_hand.place_card(card)
	cancelled.emit()
