extends "res://scenes_n_scripts/State Machines/Player States/AirState.gd"
class_name JumpState

func enter():
	player.sprite.play("jump")

func physics_update(delta):
	
	super.physics_update(delta)
	
	if player.velocity.y >= 0:
		state_machine.change_state("FallState")
