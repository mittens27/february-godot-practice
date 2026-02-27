extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Player.player_died.connect(_on_player_player_died)

var waiting_for_restart := false

func _on_player_player_died():
	waiting_for_restart = true

func _input(event):
	if waiting_for_restart and event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()
