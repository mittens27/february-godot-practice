extends CanvasLayer

enum hpState { THREE, TWO, ONE, ZERO }
var state : hpState = hpState.THREE

@export var player: Node
@onready var sprite := $healthBar


func _ready():
	add_to_group("UI")
	player.health_changed.connect(_on_player_health_changed)
	_on_player_health_changed(player.health)
	
	var deathNote := $deathNote
	deathNote.visible = false
	
func _physics_process(_delta):
	
	match state:
		hpState.THREE:
			sprite.play("3_hearts")
		hpState.TWO:
			sprite.play("2_hearts")
		hpState.ONE:
			sprite.play("1_heart")
		hpState.ZERO:
			sprite.play("0_hearts")
	
func update_coins(amount):
	$coinLabel.text = "Coins: %d" % amount
	
func _on_player_health_changed(value):
	update_hearts(value)
	
func update_hearts(value):
	var hp = value
	if hp == 3:
		state = hpState.THREE
	elif hp == 2:
		state = hpState.TWO
	elif hp == 1:
		state = hpState.ONE
	else:
		state = hpState.ZERO


func _on_player_player_died():
	toggle_death_note()

func toggle_death_note():
	var deathNote = $deathNote
	deathNote.visible = not deathNote.visible
