extends Node

class_name Board

var house_hand : HouseHand
var player_hand : PlayerHand
var core_deck : CoreDeck

var player_trades : PlayerTrades
var house_trades : HouseTrades

var discard_pile : DiscardPile
var discard_popup : DiscardPopup

var value_highlight : ValueHighlight

func _ready() -> void:
	house_hand = $HouseHand
	player_hand = $PlayerHand
	core_deck = $CoreDeck

	player_trades = $PlayerTrades
	house_trades = $HouseTrades

	discard_pile = $DiscardPile
	discard_popup = $DiscardPopup
	discard_popup.connect("discarded", _on_discard_popup_discarded)
	discard_popup.connect("cancelled", _on_discard_popup_cancelled)
	
	value_highlight = $ValueHighlight

	start_game()

func start_game() -> void:
	core_deck.deal_starting_cards(player_hand)
	core_deck.deal_to_house(house_hand)

func trade() -> void:
	if player_trades.total_value >= house_trades.total_value && player_trades.total_value > 0:
		# make the trade
		AudioManager.PlayEffect(self, "ChangeKlinks")
		
		for slot in house_hand.card_slots:
			if !slot.is_empty():
				for card in slot.cards:
					await discard_pile.discard(card).finished
					
		var tween : Tween = get_tree().create_tween()
		
		tween.tween_callback(func():
			# Discard the player's cards
			for slot in player_trades.card_slots:
				if !slot.is_empty():
					for card in slot.cards:
						discard_pile.discard(card)
		)
		player_trades.calculate_total_value(tween)

		tween.tween_callback(func():
			# Move the house cards into the player's hand
			for slot in house_trades.card_slots:
				if !slot.is_empty():
					for card in slot.cards:
						player_hand.place_card(card)
		)
		# TODO some extra juice
		
		# Deal the next round
		# Discard current house hand

		core_deck.deal_to_house(house_hand)

	else:
		# Don't make the trade.
		#TODO Raise an error message
		Logs.Debug("Not enough points for the trade")
		AudioManager.PlayEffect(self, "error")
		value_highlight.highlight()
		

func show_discard_popup() -> void:
	#TODO animate (a bit of a bounce?)
	Globals.scene.PauseForDiscardPopup()
	discard_popup.show()

func _on_discard_popup_discarded() -> void:
	#TODO animate
	discard_popup.hide()
	
	AudioManager.PlayEffect(self, "ShortChangeKlinks")
	
	# Discard the house's cards
	for slot in house_hand.card_slots:
		if !slot.is_empty():
			for card in slot.cards:
				await discard_pile.discard(card).finished

	# Discard the house's trade cards
	for slot in house_trades.card_slots:
		if !slot.is_empty():
			for card in slot.cards:
				await discard_pile.discard(card).finished

	core_deck.deal_to_house(house_hand)

	Globals.scene.UnpauseForDiscardPopup()

	# Check to see if the player has lost all their cards
	player_hand.lose_check()

func _on_discard_popup_cancelled() -> void:
	#TODO animate (a bit of a bounce?)
	discard_popup.hide()
	Globals.scene.UnpauseForDiscardPopup()
