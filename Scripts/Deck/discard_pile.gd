extends Node2D

class_name DiscardPile

var discarded_cards : Array[CardDescriptor] = []

func discard(card : Card) -> Tween:
	var card_tween = get_tree().create_tween()
	
	discarded_cards.append(card.descriptor)
	card_tween.tween_property(card, "global_position", global_position, 0.1)
	card_tween.tween_callback(func():
		if card.current_slot != null:
			card.current_slot.remove_card(card)
		card.queue_free()
	)
	card_tween.play()
	
	return card_tween

func clear() -> void:
	discarded_cards.clear()

func display_deck() -> void:
	Globals.scene.deck_display.draw(discarded_cards, true)
func clear_display_deck() -> void:
	Globals.scene.deck_display.clear()
