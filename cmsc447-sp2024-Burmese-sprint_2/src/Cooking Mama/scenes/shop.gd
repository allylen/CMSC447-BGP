extends Node2D

var points_request: HTTPRequest
var points
@onready
var point_label = $d_points

# Called when the node enters the scene tree for the first time.
func _ready():
	points_request = HTTPRequest.new()
	request_user_points(Global.user_name)


func _on_texture_button_pressed():
	get_tree().change_scene_to_file("res://.godot/exported/133200997/export-3ad5c15c4f3250da0cc7c1af1770d85f-main.scn")
	
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
		json.parse(body.get_string_from_utf8())
		if json.error == OK and json.result["success"]:
			points = int(json.result["points"])
			point_label.text = points
			print("User has points: ", points)
		else:
			push_error("Failed to fetch points: " + (json.result.get("error", "Unknown error")))
	else:
		push_error("HTTP request failed with code: " + str(response_code))
