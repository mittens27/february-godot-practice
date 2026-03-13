extends TileMapLayer

@export var fade_time := 0.5

func _ready():
	Events.wall_switch_activated.connect(_on_switch_activated)
	
func _on_switch_activated(switch):
	fade_out()
	disable_collision()
	print("Button signal received!")

func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_time)
	
func disable_collision():
	var body := $"../FadeableWallBlocker"
	body.set_deferred("collision_layer", 0)
	body.set_deferred("collision_mask", 0)
