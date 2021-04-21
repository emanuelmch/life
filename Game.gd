extends Node2D

onready var game_field = $ViewportContainer/GameField

func _on_target_speed_changed(target_speed):
	$TargetFPS.text = "Target FPS: %d" % target_speed

func _on_GameField_actual_speed_changed(actual_speed):
	$ActualFPS.text = "Actual FPS: %d" % actual_speed
