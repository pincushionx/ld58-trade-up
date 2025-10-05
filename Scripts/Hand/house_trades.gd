extends Hand

class_name HouseTrades

var total_value_label : Label
var total_value : int = 0

## Override
func _on_ready() -> void:
	total_value_label = $TotalValueLabel
	total_value_label.text = "0";

## Override
func _on_place_card(_slot : CardSlot, _card : Card) -> void:
	calculate_total_value()

## Override
func _on_slot_card_removed(_slot : CardSlot, _card : Card) -> void:
	calculate_total_value()
	

func calculate_total_value() -> int:
	var cards : Array[Card] = []
	for slot in card_slots:
		if !slot.is_empty():
			cards.append(slot.cards[0])

	var value : int = 0
	for card in cards:
		value += card.current_value

	total_value = value
	total_value_label.text = "%s" % total_value

	return value
