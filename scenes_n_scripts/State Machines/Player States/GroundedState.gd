extends "res://scenes_n_scripts/State Machines/Player States/PlayerState.gd"
class_name GroundedState

# Called when the node enters the scene tree for the first time.
func physics_update(delta):
	if player.has_jumped:
		player.has_jumped = false
		
	player.apply_horizontal_movement(delta)
	player.update_jump_buffer(delta)
	
	if  player.jump_buffer_timer > 0 and not player.has_jumped:
		if player.is_on_floor() and player.coyote_timer > 0:
			player.perform_jump()
	
	if not player.is_on_floor():
		player.coyote_timer = player.coyote_time
		state_machine.change_state("FallState")
