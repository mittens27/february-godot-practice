extends CharacterBody2D

enum EnemyState { RUN, DIE }

var state : EnemyState = EnemyState.RUN

@onready var ground_check := $RayCast2D
@onready var sprite := $AnimatedSprite2D
@onready var health_component := $HealthComponent
@onready var hurtbox := $Hurtbox
@onready var hitbox := $Attack/Hitbox

@export var enemy_maxHealth: int = 2
var enemy_health: int

@export var speed := 40.0
@export var gravity := 900.0
@export var damage := 1

var direction := 1 #start moving right
var friction := 10000.0

var turn_cooldown := 0.1
var turn_timer := 0.0

var hitstun_time := 0.2
var hitstun_timer := 0.0

func _ready():
	health_component.died.connect(_on_died)
	hurtbox.hit_received.connect(_on_hit_received)
	hurtbox.monitoring = true
	hitbox.monitoring = true

func _physics_process(delta):
	if hitstun_timer > 0:
		hitstun_timer -= delta
		velocity.x = move_toward(velocity.x, 0, 800 * delta)
		move_and_slide()
		return
		
	#gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
		ground_check.scale.x = -1 if sprite.flip_h else 1
	
	turn_timer -= delta
	
	if turn_timer <= 0:
		# turn around if hitting wall
		if is_on_wall():
			turn()
			
		# turn around if no ground ahead
		elif is_on_floor() and not ground_check.is_colliding():
			turn()
	
	move_and_slide()
	
	match state:
		EnemyState.RUN:
				velocity.x = direction * speed
				sprite.play("run")
		EnemyState.DIE:
			velocity.x = 0
			remove_from_group("enemies")
			
func turn():
		direction *= -1
		ground_check.position.x *= -1
		turn_timer = turn_cooldown

func _on_hit_received(source_position: Vector2):
	apply_knockback(source_position)

func apply_knockback(source_position: Vector2):
	var knockback_dir = (global_position - source_position).normalized()
	velocity = knockback_dir * 400
	hitstun_timer = hitstun_time
	
func _on_died():
	hurtbox.monitoring = false
	hitbox.monitoring = false
	state = EnemyState.DIE
	sprite.play("die")
	$SFXManager/die.play()
	print("Enemy killed")
