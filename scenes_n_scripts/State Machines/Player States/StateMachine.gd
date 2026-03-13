extends Node
class_name StateMachine

@export var starting_state : PlayerState

var current_state : PlayerState
var player

func _ready():
	
	player = get_parent()
	
	for child in get_children():
		child.player = player
		child.state_machine = self

func start():
	change_state(starting_state.name)

func physics_update(delta):
	if current_state:
		current_state.physics_update(delta)

func change_state(state_name : String):
	if current_state:
		current_state.exit()
	
	current_state = get_node(state_name)
	current_state.enter()
