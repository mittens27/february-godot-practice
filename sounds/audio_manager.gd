extends Node

@onready var music_player = $MusicPlayer
@onready var ui_player = $UISoundPlayer

@export var sound_library : SoundLibrary

const MAX_SIMULTANEOUS_SFX = 10

func _ready():
	Events.attack_landed.connect(_on_attack_landed)

func play_music(stream: AudioStream):
	music_player.stream = stream
	music_player.play()

func play_ui(stream: AudioStream):
	ui_player.stream = stream
	ui_player.play()
	
func play_sfx(id: String, position: Vector2):
	if get_child_count() > MAX_SIMULTANEOUS_SFX:
		return
	
	var matches = []
	
	for key in sound_library.sounds.keys():
		if key.begins_with(id):
			matches.append(sound_library.sounds[key])
			
	if matches.is_empty():
		return
		
	var sound = matches.pick_random()
	
	var player = AudioStreamPlayer2D.new()
	
	player.stream = sound
	player.global_position = position
	player.bus = "SFX"
	
	add_child(player)
	
	player.pitch_scale = randf_range(0.9, 1.1)
	
	player.play()
	
	player.finished.connect(player.queue_free)

func _on_attack_landed(attacker, target, attack_data):
	if attack_data.hit_sound != "" and attacker.is_in_group("player"):
		play_sfx(attack_data.hit_sound, target.global_position)
