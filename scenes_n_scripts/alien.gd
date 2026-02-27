extends CharacterBody2D

enum EnemyState { RUN, DIE }

var state : EnemyState = EnemyState.RUN

@export var enemy_maxHealth: int = 2
var enemy_health: int
var invulnerable := false

@export var speed := 40.0
@export var gravity := 900.0

var direction := 1 #start moving right
var friction := 10000.0

var turn_cooldown := 0.1
var turn_timer := 0.0

@onready var ground_check := $RayCast2D
@onready var sprite := $AnimatedSprite2D

@export var damage := 1

func _ready():
	enemy_health = enemy_maxHealth

func _physics_process(delta):
	
	#gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if velocity.x != 0 and not invulnerable:
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
	
	#update_animation()
	
	match state:
		EnemyState.RUN:
			if not invulnerable:
				velocity.x = direction * speed
				sprite.play("run")
		EnemyState.DIE:
			velocity.x = 0
			remove_from_group("enemies")
			collision_layer &= ~(1 << (3 - 1))
			collision_mask &= ~(
				(1 << (2 - 1)) |
				(1 << (5 - 1))
			)
			
func turn():
	if not invulnerable:
		direction *= -1
		ground_check.position.x *= -1
		turn_timer = turn_cooldown
	
#func update_animation():
	#if not is_on_floor():
		#sprite.play("fall")
	#else:
		#sprite.play("run")

func _on_hurtbox_body_entered(body):
	if body.is_in_group("player"):
		if body.velocity.y > 0 and body.global_position.y < global_position.y:
			pass
		elif body.has_method("takeDamage") and state != EnemyState.DIE:
				body.takeDamage(1, global_position)

func takeDamage(amount: int, source_position: Vector2):
	if invulnerable:
		return
		
	enemy_maxHealth -= amount
	print("Enemy health:", enemy_health)
	
	# Knockback away from damage source
	if not invulnerable:
		var knockback_dir = (global_position - source_position).normalized()
		velocity = knockback_dir * 200
	else:
		move_toward(velocity.x, 0, friction)
	
	if enemy_maxHealth <= 0:
		die()
	else:
		start_iframes()
		
func start_iframes():
	invulnerable = true
	await get_tree().create_timer(0.1).timeout
	invulnerable = false
	
func die():
	state = EnemyState.DIE
	sprite.play("die")
	$SFXManager/die.play()
	print("Enemy killed")

#func _on_animated_sprite_2d_animation_finished():
	#if sprite.animation == "die":
		#queue_free()
