extends Node2D

var points_request: HTTPRequest
var points



# Called when the node enters the scene tree for the first time.
func _ready():
	points_request = HTTPRequest.new()
	add_child(points_request)
	request_user_points(Global.user_name)
	points_request.connect("request_completed", _on_points_request_completed)
	

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
		var error = json.parse(body.get_string_from_utf8())  # Store the parsing error code
		if error == OK:
			# Now that parsing was successful, we can safely access json.result
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




func _on_disc_one_pressed():
	if Global.sound_track == "track_one":
		pass
	else:
		Global.sound_track == "track_one"
		AudioPlayer.play_track_one()
		
		



func _on_disc_two_pressed():
	if Global.sound_track == "track_two":
		pass
	else:
		pass


func _on_disc_three_pressed():
	if Global.sound_track == "track_three":
		pass
	else:
		pass
		


