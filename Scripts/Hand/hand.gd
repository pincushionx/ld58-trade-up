extends Node2D

class_name Hand

var card_slots : Array[CardSlot] = []

func _ready() -> void:
	for slot in get_children():
		if slot is CardSlot:
			slot.hand = self
			slot.connect("card_removed", _on_slot_card_removed)
			card_slots.append(slot)
	_on_ready()

## Virtual
func _on_ready() -> void:
	pass

## Places a card in the first available slot
## Returns true on success, false otherwise
func place_card(card : Card) -> bool:
	for slot in card_slots:
		if slot.is_empty():
			slot.place_card(card)
			
			_on_place_card(slot, card)
			return true
	AudioManager.PlayEffect(self, "error")
	return false

## Virtual
func _on_place_card(_slot : CardSlot, _card : Card) -> void:
	pass

## Virtual
func _on_slot_card_removed(_slot : CardSlot, _card : Card) -> void:
	pass
