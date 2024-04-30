extends Node2D

var login_request: HTTPRequest
var entered_username
func _ready():
	login_request = HTTPRequest.new()
	add_child(login_request)
	login_request.connect("request_completed", _on_login_request_node_request_completed)

func _on_line_edit_text_submitted(username):
	entered_username = username
	var url = "http://localhost:8023/login"
	var headers = PackedStringArray(["Content-Type: application/json"])
	var body_json = {"username": username}
	var body = JSON.stringify(body_json)
	if login_request.is_processing():
		push_error("Request is already in progress.")
		return
	var error = login_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("Failed to start HTTP request. Error code: " + str(error))

func _on_login_request_node_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response = json.get_data()
		if response:
			Global.logged_in = true
			Global.user_name = entered_username
			get_tree().change_scene_to_file("res://scenes/main.tscn")
		else:
			push_error("Login failed: " + (json.result.get("error", "Unknown error")))
	else:
		push_error("HTTP request failed with code: " + str(response_code))


func _on_back_pressed():
	get_tree().change_scene_to_file("res://.godot/exported/133200997/export-3ad5c15c4f3250da0cc7c1af1770d85f-main.scn")
