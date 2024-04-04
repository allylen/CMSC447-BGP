extends Node2D


func _ready():
	AudioPlayer.play_menu_music()
	if Global.username != "":
		$"Create Account".hide()
		$"Leaderboard".position.y -= 50
		$"QUIT".position.y -= 20
		$"LOGIN".set_text("PLAY")

func _on_quit_pressed():
	Sfx.play_sfx()
	get_tree().quit()

func _on_leaderboard_pressed():
	pass


func _on_create_account_pressed():
	Sfx.play_sfx()
	if Global.username == "":
		get_tree().change_scene_to_file("res://scenes/create_account.tscn")


func _on_login_pressed():
	Sfx.play_sfx()
	if Global.username != "":
		get_tree().change_scene_to_file("res://scenes/select_level.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/create_account.tscn")
