extends Node2D

class_name DeckDisplay

var card_prefab : PackedScene = preload("res://Prefab/card.tscn")
@onready var card_container : Node2D = $CardContainer;

var label : Label
var secondary_label : Label

var start_position : Vector2 = Vector2(-200, -200)
var increment_offset : Vector2 = Vector2(200, 200)
var dimensions : Vector2i = Vector2i(3, 3)

var card_slots : Array[CardSlot] = []

func _ready() -> void:
	label = $Label
	secondary_label = $SecondaryLabel
	for slot in get_children():
		if slot is CardSlot:
			card_slots.append(slot)
	clear()

func clear() -> void:
	hide()
	#for card in card_container.get_children():
		#card_container.remove_child(card)
	for slot in card_slots:
		for card in slot.cards:
			slot.cards = []
			card_container.remove_child(card)

func draw(deck : Array[CardDescriptor], is_discard : bool) -> void:
	
	if is_discard:
		label.text = "%s Discarded Cards" % deck.size()
		secondary_label.text = "This discard pile will be reshuffled into the deck when it's empty"
	else:
		label.text = "%s Cards Remaining" % deck.size()
		secondary_label.text = "When empty, this deck will be refilled from the discard pile"

	show()

	

	for descriptor in deck:
		var slot : CardSlot = card_slots[descriptor.suit]
		if slot == null:
			Logs.Debug("Can't place card %s in deck display since slot is null" % descriptor.name);
			return

		var card : Card = card_prefab.instantiate()
		card_container.add_child(card)
		card.initialize(descriptor)
		slot.place_card(card)



func find_card_stack(haystack : CardStack, needle : CardDescriptor):
	if needle == haystack.descriptor:
		return true
	return false


class CardStack:
	var descriptor : CardDescriptor
	var count : int = 0
