extends Camera2D

@export var lookAhead := 60.0
@export var followSpeed := 4.0

var player: Node = null

var fall_death := false

func _ready():
	player = get_node_or_null("/root/Main/Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player == null:
		return
	

	var dir = player.facing_direction
	var target_x: float = dir * lookAhead
	global_position = lerp(global_position, player.global_position, followSpeed * delta)
	offset.x = lerp(offset.x, target_x, followSpeed * delta)



func _on_player_player_died():
	$bgMusic.stop()
	if fall_death == false:
		$die.play()
	else:
		$fallDie.play()

func _on_death_body_entered(body):
	if body.name == "Player":
		print("Player Fell")
		fall_death = true
