extends Resource

class_name CardDescriptor

@export var name : String
@export var number : int
@export var suit : Constants.SUIT
@export var suit_descriptor : SuitDescriptor

@export var probability : int = 1 # Probably not necessary
@export var rules : Array[Constants.CARD_RULES] = []
