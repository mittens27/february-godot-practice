extends CharacterBody2D

@onready var state_machine := $StateMachine
@onready var sprite := $AnimatedSprite2D
@onready var health_component = $HealthComponent
@onready var attack_hitbox := $Attack/Hitbox
@onready var attack := $Attack
@onready var hurtbox := $Hurtbox

@export var player_data: PlayerData

var maxSpeed := 200.0
var acceleration := 1200.0
var friction := 1500.0

var gravity := 600.0
var jumpForce := 350.0
var fall_gravity_multiplier := 1.2   
var jump_cut_gravity_multiplier := 2.5

var invulnerability_time := 0.5
var is_invulnerable = false
var flicker_speed = 0.1
var flicker_time = 0.0

var facing_direction := 1

var coyote_time := 0.12
var coyote_timer := 0.0

var jump_buffer_time := 0.12
var jump_buffer_timer := 0.0
var has_jumped := false

var combo_step := 0
var combo_queued := false
const MAX_COMBO := 3

var attack_impulse_applied := false
var attack_lunge_speed := maxSpeed * 0.65
var attack_jump_multiplier := 0.5

func _ready():
	state_machine.start()
	apply_player_data()
	
	#Events.player_fell.connect(_on_player_fell)
	health_component.died.connect(_on_died)
	health_component.health_changed.connect(_on_health_component_health_changed)
	hurtbox.hit_received.connect(_on_hit_received)
	sprite.frame_changed.connect(_on_frame_changed)
	Events.coin_collected.connect(_on_coin_collected)
	
	attack_hitbox.monitoring = false
	attack_hitbox.monitorable = false

func _physics_process(delta):
	# Makes sprite opacity flicker when hurt
	if is_invulnerable:
		flicker_time += delta
		if flicker_time >= flicker_speed:
			flicker_time = 0.0
			var current_alpha = sprite.modulate.a
			sprite.modulate.a = 0.1 if current_alpha == 1.0 else 1.0
	
	if velocity.x > 0:
		facing_direction = 1
	elif velocity.x < 0:
		facing_direction = -1
	
	if Input.is_action_just_pressed("attack"):
		if state_machine.current_state is AirAttackState or state_machine.current_state is GroundedAttackState:
			combo_queued = true
		else:
			start_attack()
	
	state_machine.physics_update(delta)

	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
		attack.scale.x = -1 if sprite.flip_h else 1
		
	#floor_snap_length = 6
	update_jump_buffer(delta)
	state_machine.physics_update(delta)
	move_and_slide()

func apply_horizontal_movement(delta):
	# Horizontal Input
	var inputDir := Input.get_axis("ui_left", "ui_right")

	# Apply horizontal movement with acceleration
	if inputDir != 0:
		velocity.x = move_toward(velocity.x, inputDir * maxSpeed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		
func apply_gravity(delta):
	
	var g := gravity
	
	#faster falling gravity
	if velocity.y > 0:
		g *= fall_gravity_multiplier
		
	#short hop when releasing jump early
	if velocity.y < 0 and not Input.is_action_pressed("ui_accept"):
		g *= jump_cut_gravity_multiplier
	
	if not is_on_floor():
		velocity.y += g * delta

func update_jump_buffer(delta):
	# Track buffered jump input
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0)
		
func perform_jump():
	
		has_jumped = true
		
		Events.player_jumped.emit(self)
		
		var jump_strength := jumpForce
		# Weaken jump if attacking
		if (state_machine.current_state is GroundedAttackState or state_machine.current_state is AirAttackState):
			jump_strength *= attack_jump_multiplier
		
		velocity.y = -jump_strength
		
		jump_buffer_timer = 0
		coyote_timer = -1
		
		state_machine.change_state("JumpState")
		
func _on_coin_collected(player):
	GameMan.coins += 1
	print("Coins:", GameMan.coins)
	Events.coin_amount_changed.emit(GameMan.coins)

func _on_hit_received(attack_data, source_position: Vector2):
	#$SFXManager/hurt.play()
	health_component.damage(attack_data.damage)
	apply_knockback(attack_data.knockback, source_position)
	flicker()

func apply_knockback(force, source_position: Vector2):
	# Knockback away from damage source
	var knockback_dir = (global_position - source_position).normalized()
	velocity = knockback_dir * force

func flicker():
	if is_invulnerable:
		return
	is_invulnerable = true
	await get_tree().create_timer(invulnerability_time).timeout
	is_invulnerable = false
	sprite.modulate.a = 1.0

func _on_died():
	print("Player died.")
	GameMan.coins = 0
	GameMan.player_health = 0
	Events.player_died.emit()
	queue_free()

func bounce():
	velocity.y = -280
	Events.player_slammed.emit(self)

func _on_stompbox_body_entered(body):
	if body.is_in_group("enemies"):
		bounce()
		body._on_died()

func _on_animated_sprite_2d_animation_finished():
	if combo_step > 0:
		if combo_queued and combo_step < MAX_COMBO:
			combo_queued = false
			start_attack()
		else:
			end_combo()
			
func start_attack():
	if is_on_floor():
		state_machine.change_state("GroundedAttackState")
	else:
		state_machine.change_state("AirAttackState")
	
	combo_step += 1
	combo_step = clamp(combo_step, 1, MAX_COMBO)
	
	attack_impulse_applied = false
	
	match combo_step:
		1: sprite.play("attack_one")
		2: sprite.play("attack_two")
		3: sprite.play("attack_three")
		
func end_combo():
	combo_step = 0
	combo_queued = false
	
	attack_hitbox.monitorable = false
	attack_hitbox.monitoring = false
	
	if is_on_floor():
		state_machine.change_state("IdleState")
	else:
		state_machine.change_state("FallState")
	
func _on_frame_changed():
	#defaults to OFF first
	attack_hitbox.monitorable = false
	attack_hitbox.monitoring = false
	
	if not (state_machine.current_state is GroundedAttackState or state_machine.current_state is AirAttackState):
		return
	
	match sprite.animation:
		"attack_one":
			if sprite.frame >= 0 and sprite.frame <= 1:
				attack_hitbox.monitoring = true
				attack_hitbox.monitorable = true
		"attack_two":
			if sprite.frame >= 0 and sprite.frame <= 1:
				attack_hitbox.monitoring = true
				attack_hitbox.monitorable = true
		"attack_three":
			if sprite.frame >= 0 and sprite.frame <= 1:
				attack_hitbox.monitoring = true
				attack_hitbox.monitorable = true
				
func apply_player_data():
	if GameMan.player_health <= 0:
		GameMan.player_health = player_data.max_health
		
	health_component.initialize(
		player_data.max_health,
		GameMan.player_health
		)

func _on_health_component_health_changed(current_health):
	GameMan.player_health = current_health
	Events.player_health_changed.emit(current_health)
