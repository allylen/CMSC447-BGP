extends Node2D

@onready var create_account_request = $create_account_request_node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.





func _on_button_pressed():
	Sfx.play_sfx()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_line_edit_text_submitted(new_text):
	Sfx.play_sfx()
	Global.username = new_text
	make_create_account_request(new_text)
	
func make_create_account_request(username):
	var url = "http://localhost:8000/create_account" 
	var headers = ["Content-Type: application/json"]
	var body = {"username": username}
	
	var error = $create_account_request.request(url, headers, false, HTTPClient.METHOD_POST, JSON.stringify(body))
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		
func _on_create_account_request_node_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		var parse_result = json.parse(body.get_string_from_utf8())
		if parse_result.error == OK:
			var response = parse_result.result
			if response.get("success", false):
				get_tree().change_scene_to_file("res://scenes/select_level.tscn")
			else:
				push_error("Account creation failed.")
		else:
			push_error("Failed to parse JSON response.")
	else:
		push_error("HTTP request failed.")
