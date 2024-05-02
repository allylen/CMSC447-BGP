extends CharacterBody2D

func _ready():
	# connect event signal
	set_process_input(true)

func _physics_process(delta):
	# player / bun movement
	if Input.is_action_pressed("ui_right"):
		position.x += 6
	if Input.is_action_pressed("ui_left"):
		position.x -= 6
