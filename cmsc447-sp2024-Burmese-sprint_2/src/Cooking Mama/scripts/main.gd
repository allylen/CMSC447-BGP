extends Node2D


func _ready():
	AudioPlayer.play_menu_music()
	if Global.logged_in == true:
		$"Create Account".hide()
		$"Leaderboard".position.y -= 50
		$"Login".set_text("PLAY")
		
		
func _input(ev):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().change_scene_to_file("res://scenes/options.tscn")
	

func _on_leaderboard_pressed():
	get_tree().change_scene_to_file("res://scenes/leaderboard.tscn")


func _on_create_account_pressed():
	Sfx.play_sfx()
	if Global.logged_in == false:
		get_tree().change_scene_to_file("res://scenes/create_account.tscn")


func _on_login_pressed():
	Sfx.play_sfx()
	if Global.logged_in != false:
		get_tree().change_scene_to_file("res://scenes/select_level.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/login.tscn")


func _on_shop_pressed():
	if Global.logged_in != false:
		get_tree().change_scene_to_file("res://scenes/shop.tscn")
