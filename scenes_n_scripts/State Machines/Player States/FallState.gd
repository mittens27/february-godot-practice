extends "res://scenes_n_scripts/State Machines/Player States/AirState.gd"
class_name FallState

func enter():
	player.sprite.play("fall")
