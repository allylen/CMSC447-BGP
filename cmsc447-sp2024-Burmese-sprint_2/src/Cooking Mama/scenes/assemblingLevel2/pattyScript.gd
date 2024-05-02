extends Area2D

var speed = 350  # Adjust the falling speed as needed
var is_stopped = false
var bottomBunNode = null
var pointsNode = null
var is_colliding = false
var amount = 0
var round_ended = false

func _ready():
	# get parent node
	var parent_node = get_parent()
	# get bun node
	bottomBunNode = parent_node.get_node("bottomBunNode")
	# get points node
	pointsNode = parent_node.get_node("Points")
	var random_x = randi_range(-375, 375)
	position.x = random_x
	set_process_input(true)

func _process(delta):
	if !is_colliding:
		# burger move downwards until collision is met
		position.y += speed * delta
		if round_ended:
			# end round by switching
			end()
	else:
		# update post to follow bottom bun
		position.x = bottomBunNode.position.x + amount

func collision():
	is_colliding = true
	# calculate points & update accordingly using points node
	amount = position.x - bottomBunNode.position.x
	pointsNode.increment_points((int)((400 - abs(amount))/4))
	
func end():
	# covers both winning and loss case
	# switch scene to endRound scene to display updated points
	get_tree().change_scene_to_file("res://scenes/assemblingLevel2/endRound.tscn")

func _on_area_2d_area_entered(area):
	collision()

func _on_game_over_area_area_entered(area):
	round_ended = true
