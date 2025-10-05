extends Area2D

class_name CardStatHover

enum WHICH {
	VALUE
}
@export var which : WHICH

var card : Card

func _enter_tree() -> void:
	card = get_parent()
