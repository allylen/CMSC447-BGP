extends Area2D

var speed = 300  # Adjust the falling speed as needed
var is_stopped = false
var bottomBunNode = null
var is_colliding = false


func _ready():
	# get parent node
	var parent_node = get_parent()
	bottomBunNode = parent_node.get_node("bottomBunNode")
	set_process_input(true)

func _process(delta):
	if !is_colliding:
		position.y += speed * delta  # burger move downwards until collision is met
	else:
		# update post to follow bottom bun
		position.x = bottomBunNode.position.x

func _on_area_2d_area_entered(area):
	is_colliding = true
