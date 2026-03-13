extends "res://scenes_n_scripts/State Machines/Player States/GroundedState.gd"
class_name RunState

func enter():
	player.sprite.play("run")

func physics_update(delta):
	
	super.physics_update(delta)
	
	if abs(player.velocity.x) <= 10:
		state_machine.change_state("IdleState")
