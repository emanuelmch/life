extends Node2D

onready var game_field = $ViewportContainer/GameField

func _on_Timer_timeout():
	$TargetFPS.text = "Target FPS: %d" % game_field.target_speed
	$ActualFPS.text = "Actual FPS: %d" % game_field.actual_speed
