extends Node2D

var activated := false
var player_inside := false

func _process(delta):
	if player_inside and Input.is_action_just_pressed("ui_use"):
		activate_switch()

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		player_inside = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false
		
func activate_switch():
	if activated:
		return
	activated = true
	print("Button pressed!")
	Events.wall_switch_activated.emit()
