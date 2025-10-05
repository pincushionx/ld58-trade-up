extends Area2D

class_name Deck

var starting_deck : Array[CardDescriptor] = []
var remaining_deck : Array[CardDescriptor] = []
var card_descriptors : Dictionary[String, CardDescriptor]
var additional_cards : Array[AdditionalCards] = []


class AdditionalCards:
	var card_descriptor_id : String
	var additional_cards : int


func display_deck() -> void:
	Globals.scene.deck_display.draw(remaining_deck, false)
func clear_display_deck() -> void:
	Globals.scene.deck_display.clear()
	
func build_deck() -> void:
	
	build_starting_deck()

	# initialize remaining deck
	remaining_deck = starting_deck.duplicate()

func build_starting_deck():
	load_descriptors()

	#TODO the deck is currently using 10 of each descriptor.
	# In the future, it should consider adding specified numbers of each
	for descriptor_key in card_descriptors:
		var descriptor : CardDescriptor = card_descriptors[descriptor_key]
		for i in descriptor.probability:
			starting_deck.append(descriptor)
	
	for additional_card in additional_cards:
		if !card_descriptors.has(additional_card.card_descriptor_id):
			Logs.Error("Deck: Descriptor %s doesn't exist" % additional_card.card_descriptor_id)
			continue
		
		var descriptor : CardDescriptor = card_descriptors[additional_card.card_descriptor_id]
		for i in additional_card.additional_cards:
			starting_deck.append(descriptor)
	
	# Shuffle the deck
	starting_deck.shuffle()

func add_cards_to_deck(descriptor_key : String, count : int) -> void:
	var additional_card : AdditionalCards = AdditionalCards.new()
	additional_card.card_descriptor_id = descriptor_key
	additional_card.additional_cards = count
	additional_cards.append(additional_card)

func get_card_descriptor_path() -> String:
	return "res://Prefab/Descriptors"

func load_descriptors():
	if card_descriptors.size() == 0:
		var path : String = get_card_descriptor_path()
		var dir = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				file_name = file_name.replace(".import", "")
				card_descriptors[file_name.get_basename()] = ResourceLoader.load(path + "/" + file_name)
				file_name = dir.get_next()
		else:
			Logs.Error("An error occurred when trying to access the path.")
