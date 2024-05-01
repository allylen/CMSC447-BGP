extends Node2D


func _ready():
	AudioPlayer.play_track_one()
	var create_account_button = get_node_or_null("btn_ctn/Create Account")
	var login_button = get_node_or_null("btn_ctn/Login")
	var play_button = get_node_or_null("btn_ctn/Play")
	var shop_button = get_node_or_null("btn_ctn/Shop")

	if create_account_button and login_button and play_button and shop_button:
		if Global.logged_in:
			$"TextureRect".texture = load("res://assets/post_login_bg.png")
			create_account_button.visible = false
			login_button.visible = false
			play_button.visible = true
			shop_button.visible = true
			#print(Global.equipped_items)
			#Global.set_total_points(Global.total_points+10)
			#Global.fetch_ownership_details()
			#Global.purchase_plate("blue_plate")
			#Global.purchase_knife("pink_knife")
			#Global.equip_item("blue_knife")
			#print(Global.equipped_items)
			#Global.equip_item("pink_knife")
			#print(Global.equipped_items)
		else:
			$"TextureRect".texture = load("res://assets/pre_login_bg.png")
			create_account_button.visible = true
			login_button.visible = true
			play_button.visible = false
			shop_button.visible = false
	else:
		print("Error: One or more UI nodes could not be found.")
		
		
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



func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/select_level.tscn")
