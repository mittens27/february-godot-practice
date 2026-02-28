extends CharacterBody2D

enum PlayerState { IDLE, RUN, JUMP, FALL, ATTACK }

var state : PlayerState = PlayerState.IDLE

@onready var sprite := $AnimatedSprite2D
@onready var attackHitbox := $attackHitbox
@onready var health_component = $HealthComponent

signal player_died

var invulnerable := false

var maxSpeed := 200.0
var acceleration := 1200.0
var friction := 1500.0
var gravity := 900.0
var jumpForce := 275.0

var coins := 0

var facing_direction := 1

var coyote_time := 0.12
var coyote_timer := 0.0

var jump_buffer_time := 0.12
var jump_buffer_timer := 0.0

var combo_step := 0
var combo_queued := false
const MAX_COMBO := 3

var attack_impulse_applied := false
var attack_lunge_speed := maxSpeed * 0.35
var attack_jump_multiplier := 0.5

func _ready():
	health_component.died.connect(_on_died)

func _physics_process(delta):
	
	if velocity.x > 0:
		facing_direction = 1
	elif velocity.x < 0:
		facing_direction = -1
	
	update_jump_helpers(delta)
	
	if Input.is_action_just_pressed("attack"):
		if state != PlayerState.ATTACK:
			start_attack()
		else:
			combo_queued = true
	
	match state:
		PlayerState.IDLE:
			state_idle(delta)
		PlayerState.RUN:
			state_run(delta)
		PlayerState.JUMP:
			state_jump(delta)
		PlayerState.FALL:
			state_fall(delta)
		PlayerState.ATTACK:
			state_attack(delta)

	if velocity.x != 0 and not invulnerable:
		sprite.flip_h = velocity.x < 0
		attackHitbox.scale.x = -1 if sprite.flip_h else 1

	apply_gravity(delta)
	move_and_slide()

func state_idle(delta):
	apply_horizontal_movement(delta)
	disable_attack_hitbox()
	sprite.play("idle")
	
	if not is_on_floor() and velocity.y < 0:
		state = PlayerState.JUMP
	elif not is_on_floor() and velocity.y > 0:
		state = PlayerState.FALL
	elif abs(velocity.x) > 10:
		state = PlayerState.RUN
	
func state_run(delta):
	apply_horizontal_movement(delta)
	apply_gravity(delta)
	sprite.play("run")
	
	if not is_on_floor() and velocity.y < 0:
		state = PlayerState.JUMP
	elif not is_on_floor() and velocity.y > 0:
		state = PlayerState.FALL
	elif abs(velocity.x) <= 10:
		state = PlayerState.IDLE
	
func state_jump(delta):
	apply_horizontal_movement(delta)
	sprite.play("jump")
	
	if velocity.y > 0:
		state = PlayerState.FALL
	
func state_fall(delta):
	apply_horizontal_movement(delta)
	sprite.play("fall")
	
	if is_on_floor():
		state = PlayerState.IDLE
		
func state_attack(delta):
	enable_attack_hitbox()

	# Apply forward impulse once at attack start
	if is_on_floor():
		if not attack_impulse_applied:
			var dir = -1 if sprite.flip_h else 1
			velocity.x = dir * attack_lunge_speed
			attack_impulse_applied = true
		velocity.x = move_toward(velocity.x, 0, 300 * delta)
	
func apply_horizontal_movement(delta):
		# Horizontal Input
	var inputDir := Input.get_axis("ui_left", "ui_right")

	# Apply horizontal movement with acceleration
	if inputDir != 0:
		velocity.x = move_toward(velocity.x, inputDir * maxSpeed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		
func apply_gravity(delta):
	# Apply gravity every physics frame
	if not is_on_floor():
		velocity.y += gravity * delta

func update_jump_helpers(delta):
	# Jump only if not standing on something
	if  jump_buffer_timer > 0 and coyote_timer > 0:
		var jump_strength := jumpForce
		# Weaken jump if attacking
		if state == PlayerState.ATTACK:
			jump_strength *= attack_jump_multiplier
		
		velocity.y = -jump_strength
		jump_buffer_timer = max(jump_buffer_timer - delta, 0)
		coyote_timer = max(coyote_timer - delta, 0)

	# Track ground forgiveness
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta
		
	# Track buffered jump input
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time
		$SFXManager/jump.play()
	else:
		jump_buffer_timer -= delta

func enable_attack_hitbox():
	$attackHitbox.monitoring = true

func disable_attack_hitbox():
	$attackHitbox.monitoring = false
	
func start_attack():
	state = PlayerState.ATTACK
	attack_impulse_applied = false
	combo_step += 1
	combo_step = clamp(combo_step, 1, MAX_COMBO)
	
	match combo_step:
		1: sprite.play("attack_one")
		2: sprite.play("attack_two")
		3: sprite.play("attack_three")
		
func end_combo():
	combo_step = 0
	combo_queued = false
	state = PlayerState.IDLE
	
func add_coin():
	coins += 1
	#get_tree().call_group("UI", "updateCoins", coins)
	print("coins now:", coins)
	var ui_nodes = get_tree().get_nodes_in_group("UI")
	for ui in ui_nodes:
		if ui.has_method("update_coins"):
			ui.update_coins(coins)
func takeDamage(amount: int, source_position: Vector2):
	if invulnerable:
		return
	
	health_component.damage(amount)

	$SFXManager/hurt.play()
	
	# Knockback away from damage source
	var knockback_dir = (global_position - source_position).normalized()
	velocity = knockback_dir * 100
	
	start_iframes()

func start_iframes():
	invulnerable = true
	await get_tree().create_timer(0.6).timeout
	invulnerable = false

func _on_died():
	print("Player died.")
	player_died.emit()
	queue_free()
	
func bounce():
	velocity.y = -250
	$SFXManager/slam.play()

func _on_stompbox_body_entered(body):
	if body.is_in_group("enemies"):
		bounce()
		body._on_died()

func _on_attack_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_method("takeDamage"):
				body.takeDamage(1, global_position)
		$SFXManager/punch.play()

func _on_animated_sprite_2d_animation_finished():
	if state == PlayerState.ATTACK:
		if combo_queued and combo_step < MAX_COMBO:
			combo_queued = false
			start_attack()
		else:
			end_combo()
