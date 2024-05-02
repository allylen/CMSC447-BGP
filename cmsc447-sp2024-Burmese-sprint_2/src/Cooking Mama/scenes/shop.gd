extends Node2D

var points_request: HTTPRequest
var points
@onready var popup = $Popup
@onready var ok_button = $Popup/OkButton
@onready var cancel_button = $Popup/CancelButton
@onready var popup_label = $Popup/Label

var selectedItem = ""
var itemType = ""
var price = 600  # Assuming a fixed price for simplicity, adjust if necessary

func _ready():
	ok_button.connect("pressed", _on_ok_button_pressed)
	cancel_button.connect("pressed", _on_cancel_button_pressed)
	popup.connect("popup_hide", _on_popup_hide)
	points_request = HTTPRequest.new()
	add_child(points_request)
	points_request.connect("request_completed", _on_points_request_completed)
	request_user_points(Global.user_name)
	
	
func request_user_points(username):
	var url = "http://localhost:8023/get_points"
	var headers = PackedStringArray(["Content-Type: application/json"])
	var body_json = {"username": username}
	var body = JSON.stringify(body_json)
	var error = points_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("Failed to start HTTP request for points. Error code: " + str(error))

func _on_points_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		var error = json.parse(body.get_string_from_utf8())  # Store the parsing error code
		if error == OK:
			if json.data["success"]:  # Check if 'success' key exists and is true, indexing by [1] because godot listifies responses for some reason... [0] is points and [1] is result
				points = int(json.data["points"])
				Global.display_total_points(points)
				print("User has points: ", points)
			else:
				# Handle case where 'success' is false or not present
				var errorMessage = json.result.get("error", "Unknown error")
				push_error("Failed to fetch points: " + errorMessage)
		else:
			# Handle JSON parsing errors
			push_error("Failed to parse JSON response")
	else:
		push_error("HTTP request failed with code: " + str(response_code))



func show_popup(message: String, show_buttons: bool = true, auto_close_delay: float = 0):
	popup_label.text = message
	ok_button.visible = show_buttons
	cancel_button.visible = show_buttons
	popup.popup_centered()
	if auto_close_delay > 0:
		await get_tree().create_timer(auto_close_delay).timeout
		popup.hide()

func handle_item_pressed(item_type, item_name):
	var owned_key = item_name + "_owned"
	if Global.ownership[owned_key]:
		if Global.equipped_items[item_type] != item_name:
			if item_type == "knife":
				Global.set_active_knife(item_name)
			elif item_type == "plate":
				Global.set_active_plate(item_name)
			show_popup("Equipped: " + item_name, false, 1)  # No buttons shown, auto-close after 1 second
		else:
			show_popup("Already Equipped: " + item_name, false, 1)
	else:
		selectedItem = item_name
		itemType = item_type
		price = 600  # This could be dynamic based on item type or specific items
		show_popup("Do you want to buy this " + item_type + " for " + str(price) + " points?", true)

func _on_ok_button_pressed():
	if Global.total_points >= price:
		if itemType == "knife":
			Global.purchase_knife(selectedItem)
		elif itemType == "plate":
			Global.purchase_plate(selectedItem)
		show_popup("Purchased! Balance: " + str(Global.total_points),false, 1)
	else:
		show_popup("You do not have enough points.",false, 1)

func _on_cancel_button_pressed():
	popup.hide()

func _on_popup_hide():
	popup_label.text = ""
	ok_button.show()
	cancel_button.show()

func _on_green_knife_pressed():
	handle_item_pressed("knife", "green_knife")

func _on_purple_knife_pressed():
	handle_item_pressed("knife", "purple_knife")

func _on_pink_knife_pressed():
	handle_item_pressed("knife", "pink_knife")

func _on_purple_plate_pressed():
	handle_item_pressed("plate", "purple_plate")

func _on_blue_plate_pressed():
	handle_item_pressed("plate", "blue_plate")

func _on_green_plate_pressed():
	handle_item_pressed("plate", "green_plate")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
