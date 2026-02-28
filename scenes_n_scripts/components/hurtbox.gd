extends Area2D

signal hurt(damage, source)

@export var health_component: Node

func _ready():
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area):
	if area.has_method("get_damage"):
		var damage = area.get_damage()
		hurt.emit(damage, area)
	
		if health_component:
			health_component.damage(damage)
