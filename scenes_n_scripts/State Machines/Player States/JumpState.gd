extends "res://scenes_n_scripts/State Machines/Player States/PlayerState.gd"

func enter():
	player.sprite.play("jump")

func physics_update(delta):
	
	player.apply_horizontal_movement(delta)
	
	if player.velocity.y > 0:
		state_machine.change_state("FallState")
