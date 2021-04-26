extends Node2D

onready var _target_fps = $VBoxContainer/HBoxContainer/VBoxContainer/TargetFPS
onready var _actual_fps = $VBoxContainer/HBoxContainer/VBoxContainer/ActualFPS
onready var _game_field = $VBoxContainer/ViewportContainer/GameField

func _ready():
	_game_field.target_speed = _game_field.MAX_GAME_SPEED

func _on_target_speed_changed(target_speed):
	_target_fps.text = "Target FPS: %d" % target_speed

func _on_GameField_actual_speed_changed(actual_speed):
	_actual_fps.text = "Actual FPS: %d" % actual_speed

func _on_ClearButton_pressed():
	_game_field.reset()

func _on_GunButton_pressed():
	_game_field.do_the_gun()

func _on_ZeroButton_pressed():
	_game_field.target_speed = 0

func _on_FifteenButton_pressed():
	_game_field.target_speed = 15

func _on_ThirtyButton_pressed():
	_game_field.target_speed = 30

func _on_SixtyButton_pressed():
	_game_field.target_speed = 60
