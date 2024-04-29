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
var score_label
var score_popup
var score_popup_timer
var screen_center_x
var screen_center_y

func _ready():
	set_sprite(0) #start with first sprite
	
	# Add and position the knife sprite
	knife = Sprite2D.new()
	knife.texture = preload("res://assets/knife.png")
	add_child(knife)
	knife.position.y = get_viewport_rect().size.y / 2 - knife.texture.get_height()/2
	knife.visible = true
	
	#score label at top left
	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.position = Vector2(-500,-400)
	add_child(score_label)
	
	#popup for score
	score_popup = Label.new()
	score_popup.text = ""
	score_popup.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_popup.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	score_popup.visible = false
	add_child(score_popup)
	score_popup.position = get_viewport_rect().size / 2
	
func _process(delta):
	#Move the knife back and forth
	knife.position.x += knife_speed * delta
	if knife.position.x > get_viewport_rect().size.x:
		knife_speed = -knife_speed
	elif knife.position.x < -knife.texture.get_width():
		knife_speed = -knife_speed
		
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		# get click distance
		var click_distance = abs(knife.position.x - self.position.x)
		if click_distance <= 250:
			if get_rect().has_point(to_local(event.position)):
				if sprite_cut < len(sprites[sprite_index]["cuts"]):
					self.texture = sprites[sprite_index]["cuts"][sprite_cut]
					sprite_cut += 1
					
					var click_score = round(abs(250 - click_distance))
					score += click_score
					score_label.text = "Score: " + str(score)
					
					score_popup.text = "+" + str(click_score)
					score_popup.visible = true
					score_popup_timer = Timer.new()
					score_popup_timer.connect("timeout", self, "hide_score_popup")
					score_popup_timer.start(1.0)
				else:
					next_sprite()
func hide_score_popup():
	score_popup.visible = false
	score_popup_timer.stop()
func set_sprite(index):
	sprite_index = index
	self.texture = sprites[index]["sprite"]
	self.position.x = get_viewport_rect().size.x / 2
	self.position.y = get_viewport_rect().size.y / 2
	sprite_cut = 0
func next_sprite():
	sprite_index = (sprite_index + 1) % sprites.size()
	set_sprite(sprite_index)
func get_level_speed(level):
	return knife_speed * (level + 1 if level > 0 else 1)
func _physics_process(delta):
	knife_speed = get_level_speed(Global.get("level"))

