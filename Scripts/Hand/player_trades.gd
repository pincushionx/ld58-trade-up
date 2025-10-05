extends Hand

class_name PlayerTrades

var total_value_label : Label
var total_value : int = 0

const MIN_SET : int = 2
const MIN_SET_MINUS_ONE : int = 1
const MIN_SEQUENCE : int = 3
const MIN_SEQUENCE_MINUS_ONE : int = 2

## Override
func _on_ready() -> void:
	total_value_label = $TotalValueLabel
	total_value_label.text = "0";

## Override
func _on_place_card(_slot : CardSlot, _card : Card) -> void:
	var tween : Tween = get_tree().create_tween()
	calculate_total_value(tween)

## Override
func _on_slot_card_removed(_slot : CardSlot, _card : Card) -> void:
	var tween : Tween = get_tree().create_tween()
	calculate_total_value(tween)


############################
## Copy everything below to house_hand (not trades)
##

#TODO animate
func calculate_total_value(tween : Tween) -> void:
	tween.tween_callback(func(): pass) # add this so there's at least one tweener
	
	var cards : Array[Card] = []
	for slot in card_slots:
		if !slot.is_empty():
			cards.append(slot.cards[0])

	for card in cards:
		card.begin_update()
		card.reset_value_for_recalc()

	do_pair_bonuses(tween, cards)
	do_sequence_bonuses(tween, cards)

	var value : int = 0
	for card in cards:
		value += card.current_value
		card.end_update()

	Logs.Debug("Calculating total %s" % value)
	total_value = value
	total_value_label.text = "%s" % total_value

# TODO Animate
func do_pair_bonuses(tween : Tween, cards : Array[Card]) -> void:
	#tween.tween_callback(func():
		#tween.pause()

		var tested : Array[Card] = []
		for card in cards:
			var cards_in_number : Array[Card] = [card]
			tested.append(card)

			for comparison_card in cards:
				if !tested.has(comparison_card) && card.descriptor.number == comparison_card.descriptor.number:
					# Found a pair
					cards_in_number.append(comparison_card)
					tested.append(comparison_card)

			var cards_in_number_count : int = cards_in_number.size()
			if cards_in_number_count > MIN_SET_MINUS_ONE:
				#var pair_tween : Tween = get_tree().create_tween()
				for number_card in cards_in_number:
					number_card.add_bonus_multiplier_action(tween, "%s %s's" % [get_pair_labels(cards_in_number_count), number_card.descriptor.number], cards_in_number_count)
				#pair_tween.play()
				#Logs.Debug("PREAWAIT pair_tween")
				#await pair_tween.finished
				#Logs.Debug("POSTAWAIT pair_tween")
		#tween.play()
	#)

func get_pair_labels(num : int) -> String:
	match num:
		1: return "one"
		2: return "pair of"
		3: return "set of three"
		4: return "set of four"
		5: return "set of five"
		6: return "set of six"
		7: return "set of seven"
		8: return "set of eight"
		9: return "set of nine"
		10: return "set of ten"
	return ""


# TODO Animate
func do_sequence_bonuses(tween : Tween, cards : Array[Card]) -> void:
	#tween.tween_callback(func():
		#tween.pause()
		
		var tested : Array[Card] = []
		for card in cards:
			var cards_in_suit : Array[Card] = [card]
			tested.append(card)

			for comparison_card in cards:
				if !tested.has(comparison_card) && card.descriptor.suit == comparison_card.descriptor.suit:
					# Found a pair
					cards_in_suit.append(comparison_card)
					tested.append(comparison_card)

			cards_in_suit.sort_custom(func(a : Card, b : Card):
				if a.descriptor.number < b.descriptor.number:
					return true
				return false
			)
			var last_number : int = 0
			var cards_in_sequence : Array[Card] = []
			for suit_card in cards_in_suit:
				if suit_card.descriptor.number == last_number+1 || last_number == 0:
					cards_in_sequence.append(suit_card)
				elif cards_in_sequence.size() > MIN_SEQUENCE_MINUS_ONE:
					# Sequence is done. Display it and reset the array to check for more sequences
					var sequence_count : int = cards_in_sequence.size()
					#var pair_tween : Tween = get_tree().create_tween()
					for card_in_sequence in cards_in_sequence:
						card_in_sequence.add_bonus_multiplier_action(tween, "%s %s" % [get_sequence_labels(sequence_count), card_in_sequence.get_suit_label()], sequence_count-1)
					#pair_tween.play()
					#await pair_tween.finished
					
					# reset the array for the next sequence
					cards_in_sequence = []
				else:
					# reset the array for the next sequence
					cards_in_sequence = []
				last_number = suit_card.descriptor.number

			# Repeat of above, but outside the loop to catch cards that sequenced on the last cards_in_suit
			if cards_in_sequence.size() > MIN_SEQUENCE_MINUS_ONE:
				# Sequence is done. Display it
				var sequence_count : int = cards_in_sequence.size()
				#var pair_tween : Tween = get_tree().create_tween()
				for card_in_sequence in cards_in_sequence:
					card_in_sequence.add_bonus_multiplier_action(tween, "%s %s" % [get_sequence_labels(sequence_count), card_in_sequence.get_suit_label()], sequence_count-1)
				#pair_tween.play()
				#await pair_tween.finished

				# reset the array for the next sequence
				cards_in_sequence = []
				
		#if tween.is_valid():
			#tween.play()
	#)
	#return tween
		
func get_sequence_labels(num : int) -> String:
	match num:
		1: return "one"
		2: return "two in a row"
		3: return "three in a row"
		4: return "four in a row"
		5: return "five in a row"
		6: return "six in a row"
		7: return "seven in a row"
		8: return "eight in a row"
		9: return "nine in a row"
		10: return "ten in a row"
	return ""
