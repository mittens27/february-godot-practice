extends Area2D

signal hit(target)

@export var damage := 1

@onready var attack := $Attack

func get_damage():
	return damage
	
func _ready():
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area):
	hit.emit(area)
