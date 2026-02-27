extends Area2D

@export var damage := 1

func _on_body_entered(body):
	if body.has_method("takeDamage"):
		body.takeDamage(1, global_position)
