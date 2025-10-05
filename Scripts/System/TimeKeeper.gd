extends Node

var PlayTimeElapsed : float = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.scene == null || !Globals.scene.IsGameplayPaused():
		PlayTimeElapsed += delta

func PlayTimeSince(since : float):
	return PlayTimeElapsed - since
