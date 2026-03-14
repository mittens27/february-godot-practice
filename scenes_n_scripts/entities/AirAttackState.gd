extends "res://scenes_n_scripts/State Machines/Player States/AirState.gd"
class_name AirAttackState

func enter():
	pass
	
func physics_update(delta):
	player.apply_gravity(delta)
	player.apply_horizontal_movement(delta)
	
	if player.is_on_floor():
		state_machine.change_state("GroundedAttackState")
