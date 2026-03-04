extends Area2D

signal hurt(damage, source)
signal hit_received(source_position)

@export var health_component: Node
@export var invulnerability_time := 0.5
@export var hitbox := Node

var invulnerable := false

func _ready():
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area):
	if invulnerable:
		return
	
	if area.has_method("get_damage"):
		var damage = area.get_damage()
		hurt.emit(damage, area)
	
		if health_component:
			health_component.damage(damage)
			start_invulnerability()
	
		hit_received.emit(area.global_position)
	
func start_invulnerability():
	invulnerable = true
	hitbox.monitorable = false
	await get_tree().create_timer(invulnerability_time).timeout
	invulnerable = false
	hitbox.monitorable = true
