extends Area2D

signal hit(target, attack_data)

@export var attack_data: AttackData

var damage: int

@onready var attack := $Attack

func get_damage():
	return attack_data.damage
	
func _ready():
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area):
		print("Hitbox detected:", area)
		hit.emit(area, attack_data)
