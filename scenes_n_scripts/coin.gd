extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var audio = $AudioStreamPlayer2D

var collected_flag := false

func _on_body_entered(body):
	if collected_flag:
		return
	if body.is_in_group("player"):
		collected_flag = true
		if body.has_method("add_coin"):
			body.add_coin()
		sprite.play("collect")
		audio.play()

func _on_animated_sprite_2d_animation_finished():
	if sprite.animation == "collect":
		queue_free()
