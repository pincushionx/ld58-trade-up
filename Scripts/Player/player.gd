extends Node2D

class_name Player

var moving_card : Card = null
var displaying_deck : Deck = null
var displaying_discard_pile : DiscardPile = null
var displaying_stat : CardStatHover = null

var focusing_card_slot : CardSlot = null

@onready var camera : Camera2D = $Camera2D

func _input(event: InputEvent) -> void:
	
	if Globals.scene.IsPausedForPopup() && !Globals.scene.IsPausedForDiscardPopup():
		return
	
	if event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			# Look for a card
			var mouse_pos = get_global_mouse_position()
			var card : Card = get_card_at(mouse_pos)
			
			if card != null && card.current_slot is CardSlot:
				
				if Globals.scene.IsPausedForDiscardPopup():
					# Discard a card
					if card.current_slot.hand is PlayerHand:
						Globals.scene.board.discard_popup.place_card(card)
					elif card.current_slot.hand is DiscardPopup:
						Globals.scene.board.player_hand.place_card(card)
				else:
					# Normal gameplay
					if card.current_slot.hand is PlayerHand:
						Globals.scene.board.player_trades.place_card(card)
					elif card.current_slot.hand is HouseHand:
						Globals.scene.board.house_trades.place_card(card)
					elif card.current_slot.hand is HouseTrades:
						Globals.scene.board.house_hand.place_card(card)
					elif card.current_slot.hand is PlayerTrades:
						Globals.scene.board.player_hand.place_card(card)


	if event is InputEventMouseMotion:
		var mouse_pos = get_global_mouse_position()
		var deck : Deck = get_deck_at(mouse_pos)

		# Display deck
		if deck != null:
			if displaying_deck != deck:
				displaying_deck = deck
				displaying_deck.display_deck()
		elif displaying_deck != null:
			displaying_deck.clear_display_deck()
			displaying_deck = null
		
		# Display discard pile
		var discard_pile : DiscardPile = get_discard_pile_at(mouse_pos)
		if discard_pile != null:
			if displaying_discard_pile != discard_pile:
				displaying_discard_pile = discard_pile
				displaying_discard_pile.display_deck()
		elif displaying_discard_pile != null:
			displaying_discard_pile.clear_display_deck()
			displaying_discard_pile = null
		
		# Focus card
		var card : Card = get_card_at(mouse_pos)
		if card != null && card.current_slot is CardSlot && card.current_slot.hand is PlayerHand:
			focusing_card_slot = card.current_slot
			card.current_slot.focus_card(card)
		elif focusing_card_slot != null:
			focusing_card_slot.relayout()
			focusing_card_slot = null
		
		# Stat hover
		#var stat : CardStatHover = get_card_stat_hover_at(mouse_pos)
		#if stat != null:
			#if displaying_stat != null:
				#if displaying_stat == stat:
					#pass
				#else:
					#match displaying_stat.which:
						#CardStatHover.WHICH.VALUE: displaying_stat.card.set_value_hover(false)
			#match stat.which:
				#CardStatHover.WHICH.VALUE: stat.card.set_value_hover(true)
			#displaying_stat = stat
		#elif displaying_stat != null:
			#match displaying_stat.which:
				#CardStatHover.WHICH.VALUE: displaying_stat.card.set_value_hover(false)
			#displaying_stat = null
		
		

func get_deck_at(mouse_pos : Vector2) -> Deck:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	var results = space_state.intersect_point(query)
	
	for result in results:
		if result.collider is Deck:
			return result.collider

	return null

func get_discard_pile_at(mouse_pos : Vector2) -> DiscardPile:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	var results = space_state.intersect_point(query)
	
	for result in results:
		if result.collider is DiscardPile:
			return result.collider

	return null

func get_card_at(mouse_pos : Vector2) -> Card:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	var results = space_state.intersect_point(query)

	results.sort_custom(func(a, b):
		if a.collider.z_index > b.collider.z_index:
			return true
		return false
	)
	for result in results:
		if result.collider is Card:
			return result.collider

	return null

func get_card_slot_at(mouse_pos : Vector2) -> CardSlot:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	var results = space_state.intersect_point(query)
	
	for result in results:
		if result.collider is CardSlot:
			return result.collider

	return null
	
func get_card_stat_hover_at(mouse_pos : Vector2) -> CardStatHover:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = mouse_pos
	query.collide_with_areas = true
	var results = space_state.intersect_point(query)
	
	for result in results:
		if result.collider is CardStatHover:
			return result.collider

	return null

func pickup_card(card : Card) -> void:
	if moving_card != null:
		print("There's already a moving card")
	
	moving_card = card
	print("Picked up card " + moving_card.name)

func place_card(card_slot : CardSlot) -> bool:
	if moving_card == null:
		Logs.Debug("place_card: Moving card is null")
		return false
	if card_slot == null:
		Logs.Debug("place_card: card_slot is null")
		return false
	if card_slot.card_in_slot != null:
		Logs.Debug("Trying to replace card that's slotted")
		return false

	card_slot.place_card(moving_card)
	moving_card = null
	return true

func drop_card() -> void:
	Logs.Debug("Dropping card " + moving_card.name)
	
	if moving_card != null:
		moving_card.return_to_slot()

	moving_card = null

func _physics_process_move_card() -> void:
	if moving_card == null:
		return

	var mouse_pos = get_global_mouse_position()
	moving_card.global_position = mouse_pos

func _physics_process(_delta: float) -> void:
	_physics_process_move_card()
	
