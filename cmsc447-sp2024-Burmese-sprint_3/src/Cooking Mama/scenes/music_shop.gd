extends Node2D


@onready var popup = $Popup 
@onready var ok_button = $Popup/OkButton  
@onready var cancel_button = $Popup/CancelButton  
@onready var popup_label = $Popup/Label 
@onready var master = $Sliders/master

var selected_disc = ""

func _ready():
	ok_button.connect("pressed", _on_ok_button_pressed)
	cancel_button.connect("pressed", _on_cancel_button_pressed)
	popup.connect("popup_hide", _on_popup_hide)

func handle_disc_pressed(track_name):
	if Global.ownership[track_name + "_owned"]:
		if Global.equipped_items["track"] != track_name: 
			Global.set_active_track(track_name)
			AudioPlayer.play_equipped_track()
			show_popup("Equipped: " + track_name, false, 1)  
		else:
			show_popup("Item Already Equipped: " + track_name, false, 1)
	else:
		selected_disc = track_name
		show_popup("Do you want to buy this disc for 1000 points?", true)

func show_popup(message: String, show_buttons: bool = false, auto_hide_delay: float = 0):
	popup_label.text = message
	ok_button.visible = show_buttons
	cancel_button.visible = show_buttons
	popup.popup_centered()
	if auto_hide_delay > 0:
		await get_tree().create_timer(auto_hide_delay).timeout
		popup.hide()

func _on_ok_button_pressed():
	if Global.total_points >= 1000:
		Global.total_points -= 1000  
		Global.purchase_music(selected_disc)
		show_popup("Purchased! Balance: " + str(Global.total_points), false, 1)  
	else:
		show_popup("You do not have enough points.", false, 1)  

func _on_cancel_button_pressed():
	popup.hide()

func _on_popup_hide():
	popup_label.text = ""
	ok_button.show()
	cancel_button.show()

func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_disc_one_pressed():
	handle_disc_pressed("track_one")
	
func _on_disc_two_pressed():
	handle_disc_pressed("track_two")
	
func _on_disc_three_pressed():
	handle_disc_pressed("track_three")


func _on_master_value_changed(value):
	pass
