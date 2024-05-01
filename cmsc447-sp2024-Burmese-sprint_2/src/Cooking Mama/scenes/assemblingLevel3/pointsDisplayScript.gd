extends Label

var pointsPlus = 0

func _ready():
	# Initialize the label text
	text = ""
	# update text with points
	text += "\n Points Gained: " #  YONAS ADD CURRENT POINTS HERE TO DISPLAY

func _on_timer_timeout():
	queue_free()
	# move to next level or main menu??
	get_tree().change_scene_to_file("res://scenes/select_level.tscn")
