extends Deck

class_name CoreDeck

var suit_descriptors : Dictionary[String, SuitDescriptor]

var card_prefab : PackedScene = preload("res://Prefab/card.tscn")


func _ready() -> void:
	build_deck()

## Override
func get_card_descriptor_path() -> String:
	return "res://Prefab/Descriptors/Core"

#TODO Animate
func refill_from_discard() -> void:
	var discard_pile : DiscardPile = Globals.scene.board.discard_pile
	remaining_deck.append_array(discard_pile.discarded_cards)
	discard_pile.clear()
	
func deal_to_house(house_hand : HouseHand) -> void:
	var tween : Tween = get_tree().create_tween()
	
	tween.tween_callback(func():
		for slot in house_hand.card_slots:
			if slot is CardSlot:
				if !slot.is_empty():
					Logs.Debug("House slot %s isn't empty" % slot.name)
					continue
				
				if remaining_deck.size() == 0:
					Logs.Debug("Core deck is empty. Refilling.")
					refill_from_discard()

				var d : CardDescriptor = remaining_deck.pop_front()

				if d == null:
					Logs.Error("Card from front of remaining deck is null")

				var card : Card = card_prefab.instantiate()
				card.initialize(d)
				add_child(card)
				card.global_position = global_position

				Logs.Debug("Slot %s dealing card %s" % [slot.name, card.name])
				slot.place_card(card)
	)
	house_hand.calculate_total_value(tween)


func pop_card(suit : int, card_number : int) -> CardDescriptor:
	for i in range(remaining_deck.size()-1, -1, -1):
		var card : CardDescriptor = remaining_deck[i]
		if card.suit == suit && card_number == card.number:
			remaining_deck.remove_at(i)
			return card
	return null

## TODO change starting cards with level of difficulty selection
func deal_starting_cards(player_hand : PlayerHand) -> void:
	
	match Globals.difficulty:
		Constants.DIFFICULTY.EASY:
			deal_all_suits_with_number(player_hand, 1)
			deal_all_suits_with_number(player_hand, 2)
			deal_all_suits_with_number(player_hand, 3)
			deal_all_suits_with_number(player_hand, 8)
			deal_all_suits_with_number(player_hand, 9)
			deal_all_suits_with_number(player_hand, 10)
		Constants.DIFFICULTY.NORMAL:
			deal_all_suits_with_number(player_hand, 1)
			deal_all_suits_with_number(player_hand, 5)
			deal_all_suits_with_number(player_hand, 10)
		Constants.DIFFICULTY.HARD:
			deal_all_suits_with_number(player_hand, 1)
			deal_all_suits_with_number(player_hand, 2)
		Constants.DIFFICULTY.VERY_HARD:
			deal_all_suits_with_number(player_hand, 1)
	
	
func deal_all_suits_with_number(player_hand : PlayerHand, card_number : int) -> void:

	for suit in Constants.NUM_SUITS:
		if remaining_deck.size() == 0:
			Logs.Debug("Patron deck is empty.")
			return

		var d : CardDescriptor = pop_card(suit, card_number)
		
		if d == null:
			Logs.Error("Requested card is null %s of %s" % [card_number, suit])
		
		var card : Card = card_prefab.instantiate()
		card.initialize(d)
		add_child(card)
		card.global_position = global_position

		Logs.Debug("Dealing card %s to player" % card.name)
		player_hand.place_card(card)


func load_descriptors():
	if suit_descriptors.size() == 0:
		var path : String = "res://Prefab/Descriptors/Suit"
		var dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				file_name = file_name.replace(".import", "")
				suit_descriptors[file_name.get_basename()] = ResourceLoader.load(path + "/" + file_name)
				file_name = dir.get_next()
		else:
			Logs.Error("An error occurred when trying to access the path.")

	if card_descriptors.size() == 0:
		for suit in Constants.NUM_SUITS:
			for number in range(1, 11):
				var d : CardDescriptor = CardDescriptor.new()
				@warning_ignore("int_as_enum_without_cast")
				d.suit = suit
				d.number = number
				d.name = "%s_of_%s" % [number, suit]
				d.suit_descriptor = suit_descriptors["suit_%s" % suit]
				card_descriptors[d.name] = d
