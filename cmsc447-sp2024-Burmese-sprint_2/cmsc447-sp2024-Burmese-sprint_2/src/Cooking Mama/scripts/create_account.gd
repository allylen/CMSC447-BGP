extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.





func _on_button_pressed():
	Sfx.play_sfx()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_line_edit_text_submitted(new_text):
	Sfx.play_sfx()
	Global.username = new_text
	get_tree().change_scene_to_file("res://scenes/select_level.tscn")
	
