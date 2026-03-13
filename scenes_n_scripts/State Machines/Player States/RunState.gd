extends "res://scenes_n_scripts/State Machines/Player States/PlayerState.gd"

func enter():
	player.sprite.play("run")

func physics_update(delta):
	
	player.apply_horizontal_movement(delta)
	
	if not player.is_on_floor():
		if player.velocity.y < 0:
			state_machine.change_state("JumpState")
		else:
			state_machine.change_state("FallState")
	
	elif abs(player.velocity.x) <= 10:
		state_machine.change_state("IdleState")
