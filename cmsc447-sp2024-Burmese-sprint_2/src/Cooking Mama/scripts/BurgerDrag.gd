extends Node2D

@onready var burg_anim = $Burger_Patty/AnimationPlayer
@onready var burg_sprite = $Burger_Patty
var level = Global.level
var selected = false
var rest_point
var rest_nodes = []

var cur_side = 1 # Current side (Starts on side 1)
var cook_level_1 = 0 # Current cooking level of side 1
var cook_level_2 = 0 # Current cooking level of side 2
var curPos1 = 0
var curPos2 = 0

const cookAnims = ["Cook", "Cook1", "Cook2", "Cook3", "Cook4"] # Number denotes stage of non-cooking side

signal startCooking
signal pauseCooking
signal resumeCooking
signal burgFlip
signal burgHeld
signal burgFinish(side1, side2)

func _ready():
	burg_anim.speed_scale = 1 + (0.5 * (level - 1)) # Speed increases by 0.5 for each level
	rest_nodes = get_tree().get_nodes_in_group("zones")
	rest_point = rest_nodes[0].global_position
	rest_nodes[0].select()


func _process(delta): # Flip action (Spacebar pressed)
	if (Input.is_action_just_pressed("Spacebar") and ((rest_point != rest_nodes[0].global_position) and (rest_point != rest_nodes[-1].global_position))):
		pauseCooking.emit()
		if (cur_side == 1):
			curPos1 = burg_anim.current_animation_position
			cur_side = 2
		else:
			curPos2 = burg_anim.current_animation_position
			cur_side = 1
		burg_anim.play("Flip")



func _on_area_2d_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("click"):
		selected = true

func _physics_process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
		burg_anim.pause() # If the burger is being picked up, don't keep cooking
		if (cur_side == 1):
			curPos1 = burg_anim.current_animation_position
		else:
			curPos2 = burg_anim.current_animation_position
		pauseCooking.emit()
		burgHeld.emit()
	else:
		global_position = lerp(global_position, rest_point, 15 * delta)
		if (rest_point == rest_nodes[-1].global_position): # If the burger is placed on the end zone, tally its score and delete it
			burg_anim.pause()
			burgFinish.emit(curPos1, curPos2)
			queue_free()
		elif (rest_point == rest_nodes[0].global_position): # If the burger is placed outside of the grill, pause cooking
			burg_anim.pause()
			pauseCooking.emit()
		else: # If the burger is placed on the grill, start cooking
			if (not burg_anim.is_playing()):
				if ((curPos1 < 0.05) && (curPos2 == 0)): # small allowance for curPos1 due to (what I assume to be) signal delay
					startCooking.emit()
				else: # If burger is at least partially cooked, no need to restart timers
					resumeCooking.emit()
				if (cur_side == 1):
					burg_anim.play(cookAnims[cook_level_2])
					burg_anim.seek(curPos1)
				else:
					burg_anim.play(cookAnims[cook_level_1])
					burg_anim.seek(curPos2)
				

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false
			var shortest_dist = 75
			for child in rest_nodes:
				var distance = global_position.distance_to(child.global_position)
				if distance < shortest_dist:
					child.select()
					rest_point = child.global_position
			

func _on_animation_player_animation_finished(anim_name):
	if (anim_name in cookAnims): # If the cook animation finishes, the burger burns
		burg_anim.play("Burn")
	elif (anim_name == "Burn"): # When burning finishes, the burger is destroyed
		queue_free()
	elif (anim_name == "Flip"):
		if (cur_side == 1):
			burg_anim.play(cookAnims[cook_level_2])
			burg_anim.seek(curPos1)
		else:
			burg_anim.play(cookAnims[cook_level_1])
			burg_anim.seek(curPos2)
		burgFlip.emit()



func _on_burger_patty_frame_changed():
	if (burg_anim.current_animation in cookAnims):
		if (cur_side == 1):
			cook_level_1 = burg_sprite.frame
			# print(cook_level_1)
		else:
			cook_level_2 = burg_sprite.frame
			# print(cook_level_2)

