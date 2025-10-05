extends Hand

class_name PlayerHand

## Override
## Places a card in the first available slot
## Returns true on success, false otherwise
func place_card(card : Card) -> bool:
	@warning_ignore("int_as_enum_without_cast")
	var slot : CardSlot = card_slots[card.descriptor.suit]
	if slot == null:
		Logs.Debug("Can't place card %s in player hand since slot is null" % card.name);
		return false
	slot.place_card(card)
	card.reset_value()
	victory_check()
	return true

func victory_check() -> bool:
	for slot in card_slots:
		if !slot.is_empty():
			if slot.cards.size() == 10:
				Globals.scene.win_level()
				return true
	return false

func lose_check() -> bool:
	for slot in card_slots:
		if !slot.is_empty():
			return false
	Globals.scene.lose_level()
	return true
