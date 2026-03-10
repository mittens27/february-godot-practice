extends Area2D

var activated := false
var player_inside := false

func _process(delta):
	if player_inside and Input.is_action_just_pressed("ui_up"):
		door()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_inside = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false
		
func door():
	if activated:
		return
	activated = true
	print("Door opened!")
	Scenes.change_scene("res://level2.tscn")
