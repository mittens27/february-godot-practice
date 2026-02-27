extends Node

signal health_changed(current, max)
signal died

@export var max_health: int = 3
var current_health: int

func _ready():
	current_health = max_health

func damage(amount: int):
	print("Damage called with:", amount)
	print("Health before:", current_health)
	
	current_health = clamp(current_health - amount, 0, max_health)
	
	print("Health after:", current_health)
	
	print("Emitting health_changed signal")
	health_changed.emit(current_health)
	
	if current_health == 0:
		print("Health is zero — emitting died")
		died.emit()

func heal(amount: int):
	current_health = clamp(current_health + amount, 0, max_health)
	health_changed.emit(current_health)
