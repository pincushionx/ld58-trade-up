extends Control

class_name ValueHighlight

var house_rect : ColorRect
var player_rect : ColorRect

var highlighting_since : float = -1

func _ready() -> void:
	house_rect = $Panel
	player_rect = $Panel2

func highlight() -> void:
	highlighting_since = TimeKeeper.PlayTimeElapsed
	show()

func stop() -> void:
	highlighting_since = -1
	hide()

func _process(_delta: float) -> void:
	if highlighting_since < 0:
		return;

	var since : float = TimeKeeper.PlayTimeSince(highlighting_since)
	if since > 3:
		stop()

	var phase : float = 1 - sin(since * 2)
	house_rect.color = Color(phase, 0.2, 0.05)
	player_rect.color = Color(phase, 0.2, 0.05)
