extends Area2D

class_name CardSlot

signal card_placed(CardSlot, Card)
signal card_removed(CardSlot, Card)

var cards : Array[Card] = []
var hand : Hand
var focusing_card : Card = null

const ITEM_INCREMENT : int = 30
const FOCUS_OFFSET : int = 70
const MAX_HEIGHT : int = 300

func is_empty() -> bool:
	return cards.size() == 0
func is_focusing_card() -> bool:
	return focusing_card != null

## Must not be called within another tween/action/rules
func place_card(card : Card) -> void:
	AudioManager.PlayEffect(self, "FlipCard")
	
	cards.append(card)
	
	# Remove the card from the source slot
	if card.current_slot != null:
		card.current_slot.remove_card(card)
	
	card.current_slot = self
	
	var card_tween = get_tree().create_tween()
	card_tween.tween_property(card, "global_position", global_position, 0.25)
	await card_tween.finished
	
	relayout() #TODO animate the sorting
	
	card_placed.emit(self, card)

## pushes other cards down to reveal the focused one
func focus_card(focus : Card) -> void:
	focusing_card = focus
	var focus_found : bool = false
	var start_position : float = global_position.y
	for i in cards.size():
		var card : Card = cards[i]
		if card == focus:
			focus_found = true
			card.global_position.y = start_position + i * ITEM_INCREMENT
		elif focus_found:
			card.global_position.y = start_position + FOCUS_OFFSET + i * ITEM_INCREMENT
		else:
			card.global_position.y = start_position + i * ITEM_INCREMENT

func relayout() -> void:
	focusing_card = null
	sort_cards()

func sort_cards() -> void:
	
	cards.sort_custom(func(a : Card, b : Card):
		if a.descriptor.number < b.descriptor.number:
			return true
		return false
		)
	
	#var full_height : float = MAX_HEIGHT
	var start_position : float = global_position.y
	
	for i in cards.size():
		var card : Card = cards[i]
		card.global_position.y = start_position + i * ITEM_INCREMENT


## Removes card data from this slot. The parenting occurs in the caller.
func remove_card(outgoing_card : Card) -> void:
	var index : int = cards.find(outgoing_card)
	if index >= 0:
		cards.remove_at(index)
		card_removed.emit(self, outgoing_card)
	sort_cards()
