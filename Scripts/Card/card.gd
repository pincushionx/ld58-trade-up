extends Area2D

class_name Card

signal current_value_updated


var bonuses_label_prefab : PackedScene = preload("res://Prefab/bonuses_label.tscn")

var descriptor : CardDescriptor
var background_sprite : Sprite2D
var suit_sprite : Sprite2D
var label : Label


var is_updating : bool = false
var preupdate_current_value : int
var preupdate_incard_bonuses : Array[String] = []


var current_slot : CardSlot = null # Managed by CardSlot.

var return_to_slot_since : float = -1
var move_to_position : Vector2


# for display
var stack_count_label : Label
var stack_count : int = 0

var current_value : int

var incard_bonus_container : Container

var value_label : RichTextLabel
var total_number_label : RichTextLabel
var bonus_label : Label
var value_card_container : Area2D
var value_log : Array[String] = [] # TODO This is no longer a log, but it might change from round to round. Even within a round
var value_log_panel : PanelContainer
var value_log_label : RichTextLabel
var is_value_hovering : bool = false


func initialize_stack_count_mode(d : CardDescriptor, count : int) -> void:
	initialize_common(d)

	stack_count = count
	stack_count_label.text = "%s" % stack_count

	# If count is 0, dim the card

func initialize(d : CardDescriptor) -> void:
	initialize_common(d)
	stack_count_label.hide()

func initialize_tutorial(d : CardDescriptor) -> void:
	initialize_common(d)
	stack_count_label.hide()
	
	# prevent the card from being moved
	monitoring = false
	monitorable = false


func reset_z_index() -> void:
	if descriptor != null:
		z_index = descriptor.number

func initialize_common(d : CardDescriptor) -> void:
	incard_bonus_container = $IncardBonusContainer
	stack_count_label = $StackCount
	label = $Label
	background_sprite = $Sprite
	suit_sprite = $SuitSprite
	value_label = $NumberLabel
	total_number_label = $TotalNumberLabel
	bonus_label = $ValueContainer/BonusLabel
	value_card_container = $ValueContainer
	value_log_panel = $ValueContainer/Log
	value_log_label = $ValueContainer/Log/RichTextLabel
	
	set_value_hover(false)

	descriptor = d
	reset_z_index()
	label.text = get_suit_label()
	if d.name != null && d.name.length() > 0:
		name = d.name
	else:
		Logs.Debug("Name not set for card descriptor")
	background_sprite.texture = d.suit_descriptor.background
	suit_sprite.texture = d.suit_descriptor.suit_icon
	
	reset_value()
	
	# Apply buffs
	#for buff in Globals.buffs:
		#for card_buff in descriptor.buffs:
			#if buff.rule == card_buff:
				#match card_buff:
					#Constants.BUFF_RULES.DRINK_BEER: add_money("for %s" % buff.label, 1)
					#Constants.BUFF_RULES.DRINK_WINE: add_money("for %s" % buff.label, 1)
					#Constants.BUFF_RULES.DRINK_WHISKEY: add_money("for %s" % buff.label, 1)
					#Constants.BUFF_RULES.DRINK_MARTINI: add_money("for %s" % buff.label, 1)
					#
					#Constants.BUFF_RULES.DRINK_ROWDY_BEER:
						#add_money("for %s" % buff.label, 5)
						#add_heat("for %s" % buff.label, 1)
					#Constants.BUFF_RULES.DRINK_FINE_WINE:
						#add_money("for %s" % buff.label, 5)
						#add_event_effect("from %s" % buff.label)
					#Constants.BUFF_RULES.DRINK_CALMING_WHISKEY:
						#add_heat("for %s" % buff.label, -1)
					#Constants.BUFF_RULES.DRINK_DIRTY_MARTINI:
						#add_event_effect("from %s" % buff.label)

	update_labels()

	
func get_suit_label() -> String:
	match descriptor.suit:
		Constants.SUIT.HEARTS: return "Hearts"
		Constants.SUIT.DIAMONDS: return "Diamonds"
		Constants.SUIT.SPADES: return "Spades"
		Constants.SUIT.CLUBS: return "Clubs"
	return "No Suit"


func add_value_action(tween : Tween, reason : String, m : int) -> void:

	tween.tween_property(value_label, "scale", Vector2(3, 3), 0.1)
	tween.tween_callback(func(): add_value(reason, m))
	tween.tween_property(value_label, "scale", Vector2.ONE, 0.1)

func begin_update() -> void:
	is_updating = true
	
	# Save values for comparison
	preupdate_current_value = current_value
	preupdate_incard_bonuses = []
	for child in incard_bonus_container.get_children():
		if child is RichTextLabel:
			preupdate_incard_bonuses.append(child.text)
	
	reset_value()

func end_update() -> void:
	is_updating = false

func reset_value_for_recalc() -> void:
	current_value = 0
	value_log.clear()
	bonus_label.text = ""

	add_value_no_label_change("card number", descriptor.number)
	Logs.Debug("reset_value_for_recalc %s" % name)

func reset_incard_bonuses():
	for child in incard_bonus_container.get_children():
		incard_bonus_container.remove_child(child)
		child.queue_free()



func reset_value() -> void:
	current_value = 0
	value_log.clear()
	bonus_label.text = ""
	
	reset_incard_bonuses()
	
	add_value("card number", descriptor.number)
	Logs.Debug("reset_value %s" % name)

func add_bonus_multiplier_action(tween : Tween, reason : String, multiplier : int) -> void:
	var incard_bonus_text : String = "%sx from %s" % [multiplier, reason]
	var text_found : bool = false
	for preupdate_bonus_text in preupdate_incard_bonuses:
		if preupdate_bonus_text == incard_bonus_text:
			text_found = true

	var incard_bonus_label : RichTextLabel = bonuses_label_prefab.instantiate()
	incard_bonus_label.text = incard_bonus_text
	incard_bonus_container.add_child(incard_bonus_label)

	if !text_found:
		tween.tween_property(incard_bonus_label, "scale", Vector2(3, 3), 0.1)
		tween.tween_property(incard_bonus_label, "scale", Vector2.ONE, 0.1)
		


	var additional_value : int = current_value * (multiplier-1)
	add_value(reason, additional_value)

	if current_value != preupdate_current_value:
		tween.tween_property(total_number_label, "scale", Vector2(3, 3), 0.1)
		tween.tween_property(total_number_label, "scale", Vector2.ONE, 0.1)



func add_value(reason : String, m : int) -> void:
	add_value_no_label_change(reason, m)
	total_number_label.text = get_value_label_text()

func get_future_value_label_text(additional_value : int) -> String:
	var v : int = additional_value + current_value
	if v != descriptor.number:
		return "= %s" % v
	else:
		return "%s" % v


func get_value_label_text() -> String:
	if current_value != descriptor.number:
		return "= %s" % current_value
	else:
		return "%s" % current_value


func add_value_no_label_change(reason : String, m : int) -> void:
	current_value += m

	if m < 0:
		value_log.push_back("[color=red]-%s[/color] %s = %s" % [m * -1, reason, current_value])
	else:
		value_log.push_back("[color=green]+%s[/color] %s = %s" % [m, reason, current_value])
	
	current_value_updated.emit()

func update_labels() -> void:
	value_label.text = "%s" % current_value

func set_value_hover(active):
	if value_log_panel == null:
		Logs.Error("value_log_panel is null")
		return
	
	is_value_hovering = active
	if active:
		value_log_panel.show()

		var label_text : String = ""
		for i in value_log.size():
			var log_entry : String = value_log[i]
			label_text += "\n" + log_entry

		value_log_label.text = label_text
	else:
		value_log_panel.hide()
