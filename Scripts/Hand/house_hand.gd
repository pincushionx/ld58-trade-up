extends Hand

class_name HouseHand

const MIN_SET_MINUS_ONE : int = 1
const MIN_SEQUENCE_MINUS_ONE : int = 2



############################
## Copy everything below to player_trades (not hand)
##

#TODO animate
func calculate_total_value(tween : Tween) -> void:
	tween.tween_callback(func():
		tween.pause()
		var inner_tween : Tween = get_tree().create_tween()

		var cards : Array[Card] = []
		for slot in card_slots:
			if !slot.is_empty():
				cards.append(slot.cards[0])

		do_reset_values(inner_tween, cards)
		do_pair_bonuses(inner_tween, cards)
		do_sequence_bonuses(inner_tween, cards)
		await inner_tween.finished
	
		if tween.is_valid():
			tween.play()
	)

# TODO Animate
func do_reset_values(tween : Tween, cards : Array[Card]) -> void:
	tween.tween_callback(func():
		for card in cards:
			card.reset_value_for_recalc()
	)

# TODO Animate
func do_pair_bonuses(tween : Tween, cards : Array[Card]) -> void:
	tween.tween_callback(func():
		tween.pause()

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
				var pair_tween : Tween = get_tree().create_tween()
				#pair_tween.parallel()
				for number_card in cards_in_number:
					#number_card.add_value("%s %s's" % [get_pair_labels(cards_in_number_count), number_card.descriptor.number], number_card.current_value * (cards_in_number_count-MIN_SET_MINUS_ONE))
					number_card.add_bonus_multiplier_action(pair_tween, "%s %s's" % [get_pair_labels(cards_in_number_count), number_card.descriptor.number], cards_in_number_count)
				pair_tween.play()
				await pair_tween.finished
					#add_bonus_multiplier_action
		tween.play()
	)

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
func do_sequence_bonuses(tween : Tween, cards : Array[Card]) -> Tween:
	#var tween : Tween = get_tree().create_tween()
	tween.tween_callback(func():
		tween.pause()
		
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
				if suit_card.descriptor.number == last_number+1:
					cards_in_sequence.append(suit_card)
				elif cards_in_sequence.size() > MIN_SEQUENCE_MINUS_ONE:
					# Sequence is done. Display it and reset the array to check for more sequences
					var sequence_count : int = cards_in_sequence.size()
					#for card_in_sequence in cards_in_sequence:
						#card_in_sequence.add_value("%s %s" % [get_sequence_labels(sequence_count), card_in_sequence.get_suit_label()], card_in_sequence.current_value * (sequence_count-MIN_SEQUENCE_MINUS_ONE))
					
					var pair_tween : Tween = get_tree().create_tween()
					#pair_tween.parallel()
					for card_in_sequence in cards_in_sequence:
						#card_in_sequence.add_value("%s %s" % [get_sequence_labels(sequence_count), card_in_sequence.get_suit_label()], card_in_sequence.current_value * (sequence_count-MIN_SEQUENCE_MINUS_ONE))
						card_in_sequence.add_bonus_multiplier_action(pair_tween, "%s %s" % [get_sequence_labels(sequence_count), card_in_sequence.get_suit_label()], sequence_count-1)
					pair_tween.play()
					await pair_tween.finished
					
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
				#for card_in_sequence in cards_in_sequence:
					#card_in_sequence.add_value("%s %s" % [get_sequence_labels(sequence_count), card_in_sequence.get_suit_label()], card_in_sequence.current_value * (sequence_count-MIN_SEQUENCE_MINUS_ONE))
					#
				var pair_tween : Tween = get_tree().create_tween()
				#pair_tween.parallel()
				for card_in_sequence in cards_in_sequence:
					#card_in_sequence.add_value("%s %s" % [get_sequence_labels(sequence_count), card_in_sequence.get_suit_label()], card_in_sequence.current_value * (sequence_count-MIN_SEQUENCE_MINUS_ONE))
					card_in_sequence.add_bonus_multiplier_action(pair_tween, "%s %s" % [get_sequence_labels(sequence_count), card_in_sequence.get_suit_label()], sequence_count-1)
				pair_tween.play()
				await pair_tween.finished

				# reset the array for the next sequence
				cards_in_sequence = []
				
		if tween.is_valid():
			tween.play()
	)
	return tween
		
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
