extends "res://scenes_n_scripts/State Machines/Player States/PlayerState.gd"

func enter():
	player.sprite.play("fall")

func physics_update(delta):
	
	player.apply_horizontal_movement(delta)
	
	if player.is_on_floor():
		state_machine.change_state("IdleState")
