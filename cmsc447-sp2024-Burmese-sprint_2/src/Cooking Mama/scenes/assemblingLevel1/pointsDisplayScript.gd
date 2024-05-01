extends Label

var pointsPlus = 0

func _ready():
	# Initialize the label text
	text = ""
	# update text with points
	text += "\n Current Points: " #  YONAS ADD CURRENT POINTS HERE TO DISPLAY

func _on_timer_timeout():
	queue_free()
	# change to next scene, which in this case is the next level or back to main?
	get_tree().change_scene_to_file("res://scenes/select_level.tscn")
