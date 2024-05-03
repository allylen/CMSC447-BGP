extends Node2D




func _on_quit_pressed():
	Sfx.play_sfx()
	get_tree().quit()





func _on_back_pressed():
	Sfx.play_sfx()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_level_one_pressed():
	Sfx.play_sfx()
	AudioPlayer.stop_music()
	get_tree().change_scene_to_file("res://scenes/node_2d.tscn")
