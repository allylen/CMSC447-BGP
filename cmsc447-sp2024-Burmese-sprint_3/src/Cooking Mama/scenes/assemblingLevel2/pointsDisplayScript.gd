extends Label

var pointsPlus = 0

func _ready():
	# Initialize the label text
	text = ""
	# update text with points
	text += "\n Current Points: " + str(Global.total_points)#  YONAS ADD CURRENT POINTS HERE TO DISPLAY

func _on_timer_timeout():
	queue_free();
	# go to next level or back to main???
	if Global.level < 3:
		Global.level += 1
	Global.set_current_level_stage(Global.level, 1)
	get_tree().change_scene_to_file("res://scenes/node_2d.tscn")
