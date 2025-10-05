extends Control

class_name ScreenTransition

var Animations : AnimationPlayer

func _enter_tree():
	Animations = $AnimationPlayer
	$ColorRect.color = Color.BLACK

func FadeIn():
	$AnimationPlayer.play_backwards("fade_out")

func FadeOut():
	$AnimationPlayer.play("fade_out")
