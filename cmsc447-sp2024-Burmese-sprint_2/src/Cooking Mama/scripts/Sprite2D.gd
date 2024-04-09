extends Sprite2D

var sprites = [
	{"sprite": preload("res://assets/tomato_top.png"), "cuts": [preload("res://assets/tomato_cut1.png"), preload("res://assets/tomato_cut2.png")]},
	{"sprite": preload("res://assets/lettuce_top.png"), "cuts": [preload("res://assets/lettuce_cut1.png"), preload("res://assets/lettuce_cut2.png")]}
]
var sprite_index = 0 #start with tomato
var sprite_cut = 0 #start with no cuts
var knife
var knife_speed = 400
var screen_center_x
var screen_center_y


func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		#need to fix this for all screen sizes
		if abs(knife.position.x - (screen_center_x - self.texture.get_width())) <= 100:
			if get_rect().has_point(to_local(event.position)):
				if sprite_cut < len(sprites[sprite_index]["cuts"]):
					self.texture = sprites[sprite_index]["cuts"][sprite_cut]
					sprite_cut += 1
					print("You clicked on the sprite - Cut ", sprite_cut)
				else:
					print("Sprite is fully cut!")
					next_sprite()
		else:
			print("You clicked at the wrong time")

func _ready():
	set_sprite(0) #start with first sprite
	
	# Add and position the knife sprite
	knife = Sprite2D.new()
	knife.texture = preload("res://assets/knife.png")
	add_child(knife)
	knife.position.y = self.position.y - 150  #align with the tomato vertically
	# calculate screen center
	screen_center_x = get_viewport_rect().size.x / 2 
	print("test", screen_center_x)
	await get_tree().create_timer(15).timeout
	queue_free()
	get_tree().change_scene_to_file("res://scenes/cooking.tscn")


	
func _process(delta):
	#Move the knife back and forth
	knife.position.x += knife_speed * delta
	if knife.position.x > get_viewport_rect().size.x / 2:
		knife_speed = -knife_speed
	elif knife.position.x < -knife.texture.get_width():
		knife_speed = -knife_speed
		
func set_sprite(index):
	sprite_index = index
	self.texture = sprites[index]["sprite"]
	sprite_cut = 0
	center_sprite()

func next_sprite():
	sprite_index = (sprite_index + 1) % sprites.size()
	set_sprite(sprite_index)

func center_sprite():
	# Need to fix centering of sprites on screen to work for all screen sizes
	screen_center_x = get_viewport_rect().size.x
	screen_center_y = get_viewport_rect().size.y
	self.position.x = screen_center_x - self.texture.get_width() / 2
	self.position.y = screen_center_y - self.texture.get_height() / 2




