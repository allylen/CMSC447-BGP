extends Area2D

var speed = 300  # falling speed
var patty = null
var is_colliding = false
var parent_node = null

func _ready():
	parent_node = get_parent()
	set_process_input(true)

func _process(delta):
	if !is_colliding:
		position.y += speed * delta  # burger move downwards until collision is met
	else:
		patty = parent_node.get_node("pattyNode") # stop falling once colision met
		position.x = patty.position.x # x pos follows previous patty

func _on_patty_node_7_area_entered(area):
	is_colliding = true
