extends Node2D

# Declare the HTTPRequest variable at the top level.
var create_account_request: HTTPRequest

# Called when the node enters the scene tree for the first time.
func _ready():
	# Create a new HTTPRequest node and add it to the current node.
	create_account_request = HTTPRequest.new()
	add_child(create_account_request)
	create_account_request.connect("request_completed", _on_create_account_request_node_request_completed)

func _on_button_pressed():
	Sfx.play_sfx()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_line_edit_text_submitted(new_text):
	Sfx.play_sfx()
	Global.username = new_text
	make_create_account_request(new_text)
	
func make_create_account_request(username):
	var url = "http://localhost:8023/create_account"
	var headers = PackedStringArray(["Content-Type: application/json"])  # Properly packed headers
	var body_json = {"username": username}
	var body = JSON.stringify(body_json)  # Convert JSON string to UTF-8 buffer
	
	# Ensure that HTTPRequest is not processing another request
	if create_account_request.is_processing():
		push_error("Request is already in progress.")
		return

	# Fixing the order and type of arguments
	var error = create_account_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request. Error code: " + str(error))

		
func _on_create_account_request_node_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var response = json.get_data()
		if (response):
			Global.logged_in = true
			get_tree().change_scene_to_file("res://scenes/select_level.tscn")
		else:
			push_error("Couldn't get json data :3")

# Optionally, clean up by removing the HTTPRequest node when done or when the scene is exited.
func _exit_tree():
	remove_child(create_account_request)
	create_account_request.queue_free()
