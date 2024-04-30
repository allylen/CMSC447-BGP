extends Sprite2D

var sprites = [
	{"sprite": preload("res://assets/tomato_top.png"), "cuts": [preload("res://assets/tomato_cut1.png"), preload("res://assets/tomato_cut2.png")]},
	{"sprite": preload("res://assets/lettuce_top.png"), "cuts": [preload("res://assets/lettuce_cut1.png"), preload("res://assets/lettuce_cut2.png")]}
]
var sprite_index = 0 #start with tomato
var sprite_cut = 0 #start with no cuts
var knife
var knife_speed = 400
var score = 0
var score_node
var popup_node
var score_popup_timer
var screen_center_x = 960 #based on 1920x1080 screen
var screen_center_y = 540 #based on 1920x1080 screen
var screen_max_x = 1920
var screen_min_x = 0
var min_score = 20
var max_click_distance = 206
var vegetables_cut = 0
var parent_node

func _ready():
	set_sprite(0) #start with first sprite
	
	# Add and position the knife sprite
	knife = Sprite2D.new()
	knife.texture = preload("res://assets/knife.png")
	add_child(knife)
	knife.position.y = screen_center_y - knife.texture.get_height()/2
	knife.visible = true
	
	parent_node = get_parent() #get parent node
	
	#score label at top left
	score_node = parent_node.get_node("ScoreNumTotal")
	
	#popup for score
	popup_node = parent_node.get_node("PopupNum")
	
func _process(delta):
	#Move the knife back and forth
	knife.position.x += knife_speed * delta
	if knife.position.x >= screen_max_x/2:
		knife_speed = -knife_speed
	elif knife.position.x <= -screen_max_x/2:
		knife_speed = -knife_speed
		
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		# get click distance
		var click_distance = abs(knife.position.x)
		if click_distance <= max_click_distance:
			if get_rect().has_point(to_local(event.position)):
				if sprite_cut < len(sprites[sprite_index]["cuts"]):
					sprite_cut += 1
					self.texture = sprites[sprite_index]["cuts"][sprite_cut-1]
					
					var click_score = round(100 - (click_distance / max_click_distance) * (100 - min_score))
					score += click_score
					
					popup_node.display_points(click_score) # do popup score
					score_node.incr_points(click_score) # incr total score
					popup_node.display_points(-1) #reset it to blank
					
					if sprite_cut == len(sprites[sprite_index]["cuts"]):
						await get_tree().create_timer(0.5).timeout
						next_sprite()
				else:
					vegetables_cut += 1
					if vegetables_cut >=2:
						get_tree().change_scene_to_file("res://scenes/cooking.tscn")
					else:
						next_sprite()
#func hide_score_popup():
#	score_popup.visible = false
#	score_popup_timer.stop()
func set_sprite(index):
	sprite_index = index
	self.texture = sprites[index]["sprite"]
	self.position.x = screen_center_x
	self.position.y = screen_center_y
	sprite_cut = 0
func next_sprite():
	sprite_index = sprite_index + 1
	if sprite_index >= 2:
		get_tree().change_scene_to_file("res://scenes/cooking.tscn")
	else:
		set_sprite(sprite_index)
func get_level_speed(level):
	return knife_speed * (level if level > 0 else 1)
func _physics_process(delta):
	knife_speed = get_level_speed(Global.get("level"))

