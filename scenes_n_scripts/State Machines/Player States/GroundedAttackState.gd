extends "res://scenes_n_scripts/State Machines/Player States/GroundedState.gd"
class_name GroundedAttackState

func enter():
	pass
	
func physics_update(delta):
	
	#Apply attack movement behaviour
	if player.is_on_floor():
		if not player.attack_impulse_applied:
			var dir = -1 if player.sprite.flip_h else 1
			player.velocity.x = dir * player.attack_lunge_speed
			player.attack_impulse_applied = true
			
		player.velocity.x = move_toward(player.velocity.x, 0, 300 * delta)
		
	else:
		state_machine.change_state("AirAttackState")
