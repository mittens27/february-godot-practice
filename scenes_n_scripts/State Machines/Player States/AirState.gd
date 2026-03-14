extends "res://scenes_n_scripts/State Machines/Player States/PlayerState.gd"
class_name AirState

func physics_update(delta):
	
	player.apply_gravity(delta)
	player.apply_horizontal_movement(delta)
	
	player.coyote_timer = max(player.coyote_timer - delta, 0)
	
	if player.is_on_floor():
		if abs(player.velocity.x) > 10:
			state_machine.change_state("RunState")
		else:
			state_machine.change_state("IdleState")
