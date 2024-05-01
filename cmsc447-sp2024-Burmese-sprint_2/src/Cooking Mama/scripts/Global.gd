extends Node

# ===/ HTTP Node for global communication /===
var http_node: HTTPRequest
var ownership_node: HTTPRequest
var music_request: HTTPRequest
var knife_request: HTTPRequest
var plate_request: HTTPRequest
var progress_request: HTTPRequest
var pts_request : HTTPRequest
var set_active_req : HTTPRequest
# === /Signals/ ===
signal points_updated(new_points)

# Is the user logged in?
var logged_in = false
var user_name = null

# Current Level Selected by the User
var level = 1 # do not set to any number less than 1 (for my sanity, pls :3)
var level_but_str = "level_one"
var stage = 1 # whatever you say pooks ^^

# Sentinel Value used to trigger display of popup
var display_popup = false
var popup_text = ""

# Variables to check if tracks are unlocked

var track_one_owned = false
var track_two_owned = false
var track_three_owned = false 
var green_knife_owned = false
var purple_knife_owned = false
var pink_knife_owned = false
var blue_knife_owned = true
var purple_plate_owned = false
var blue_plate_owned = false
var green_plate_owned = false
var white_plate = true


var ownership = {
	"track_one_owned": false,
	"track_two_owned": false,
	"track_three_owned": false,
	"green_knife_owned": false,
	"purple_knife_owned": false,
	"pink_knife_owned": false,
	"blue_knife_owned": true,
	"purple_plate_owned": false,
	"blue_plate_owned": false,
	"green_plate_owned": false,
	"white_plate_owned": true 
}


var equipped_items = {
	"knife": "blue_knife",
	"plate": "white_plate",
	"track": "track_one"
}


# Points for each level
var total_points = 0 : set = set_total_points, get = get_total_points

var stage_one_total_points = 0
var stage_two_total_points = 0
var stage_three_total_points = 0

var level_one_total_points = 0
var level_two_total_points = 0
var level_three_total_points = 0

func _ready():
	var http_request = HTTPRequest.new()
	add_child(http_node)
	ownership_node = HTTPRequest.new()
	add_child(ownership_node)
	ownership_node.connect("request_completed", _on_ownership_details_received)
	music_request = HTTPRequest.new()
	add_child(music_request)
	knife_request = HTTPRequest.new()
	add_child(knife_request)	
	plate_request = HTTPRequest.new()
	add_child(plate_request)
	progress_request = HTTPRequest.new()
	add_child(progress_request)
	pts_request = HTTPRequest.new()
	add_child(pts_request)
	set_active_req = HTTPRequest.new()
	add_child(set_active_req)
	
	
	

func set_active_knife(knife_name: String):
	if set_active_req.is_processing():
		print("A request is already processing.")
		return

	var url = "http://localhost:8023/set_active_knife"
	var body = {
		"username": user_name,
		"active_knife": knife_name
	}
	var headers = PackedStringArray(["Content-Type: application/json"])
	var json_body = JSON.stringify(body)
	set_active_req.connect("request_completed", _on_set_active_knife_response)
	set_active_req.request(url, headers, HTTPClient.METHOD_POST, json_body)

# Callback for setting active knife
func _on_set_active_knife_response(result, response_code, headers, body):
	set_active_req.disconnect("request_completed", _on_set_active_knife_response)
	
	if response_code == 200:
		print("Active knife set successfully.")
	else:
		print("Failed to set active knife. Response code:", response_code)

# Method to set active plate
func set_active_plate(plate_name: String):
	if set_active_req.is_processing():
		print("A request is already processing.")
		return

	var url = "http://localhost:8023/set_active_plate"
	var body = {
		"username": user_name,
		"active_plate": plate_name
	}
	var headers = PackedStringArray(["Content-Type: application/json"])
	var json_body = JSON.stringify(body)
	set_active_req.connect("request_completed", _on_set_active_plate_response)
	set_active_req.request(url, headers, HTTPClient.METHOD_POST, json_body)

# Callback for setting active plate
func _on_set_active_plate_response(result, response_code, headers, body):
	set_active_req.disconnect("request_completed", _on_set_active_plate_response)
	
	if response_code == 200:
		print("Active plate set successfully.")
	else:
		print("Failed to set active plate. Response code:", response_code)

# Method to set active track
func set_active_track(track_name: String):
	if set_active_req.is_processing():
		print("A request is already processing.")
		return

	var url = "http://localhost:8023/set_active_track"
	var body = {
		"username": user_name,
		"active_music": track_name
	}
	var headers = PackedStringArray(["Content-Type: application/json"])
	var json_body = JSON.stringify(body)
	set_active_req.connect("request_completed", _on_set_active_track_response)
	set_active_req.request(url, headers, HTTPClient.METHOD_POST, json_body)

# Callback for setting active track
func _on_set_active_track_response(result, response_code, headers, body):
	set_active_req.disconnect("request_completed", _on_set_active_track_response)
	
	if response_code == 200:
		print("Active track set successfully.")
	else:
		print("Failed to set active track. Response code:", response_code)
	
	

func fetch_current_level_stage():
	if progress_request.is_processing():
		print("A request is already processing.")
		return
	
	var url = "http://localhost:8023/get_current_level_stage"
	var body = {"username": user_name}
	var headers = PackedStringArray(["Content-Type: application/json"])
	var json_body = JSON.stringify(body)
	progress_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	progress_request.connect("request_completed", _on_fetch_level_stage_response)
	
func _on_fetch_level_stage_response(result, response_code, headers, body):
	progress_request.disconnect("request_completed", _on_fetch_level_stage_response)
	
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		level_but_str = json.data["current_level"]
		stage = json.data["current_stage"]
		print("Current level and stage loaded: ", level_but_str, ", ", stage)
	else:
		print("Failed to fetch current level and stage. Response code: ", response_code)
		
		
		

		
func set_current_level_stage(level, stage):
	if progress_request.is_processing():
		print("A request is already processing.")
		return

	var url = "http://localhost:8023/set_current_level_stage"
	var body = {
		"username": user_name,
		"current_level": level,
		"current_stage": stage
	}
	var headers = PackedStringArray(["Content-Type: application/json"])
	var json_body = JSON.stringify(body)
	progress_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	progress_request.connect("request_completed", _on_set_level_stage_response)

func _on_set_level_stage_response(result, response_code, headers, body):
	progress_request.disconnect("request_completed", _on_set_level_stage_response)
	
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		if json.data["success"]:
			print("Current level and stage updated successfully.")
		else:
			print("Failed to parse the response for setting level/stage")
	else:
		print("Failed to set current level and stage. Response code: ", response_code)

func purchase_music(music_name):
	send_purchase_request(music_request, "http://localhost:8023/purchase_music", music_name)

func purchase_knife(knife_name):
	send_purchase_request(knife_request, "http://localhost:8023/purchase_knife", knife_name)

func purchase_plate(plate_name):
	send_purchase_request(plate_request, "http://localhost:8023/purchase_plate", plate_name)

func send_purchase_request(node, url, item_name):
	if node.is_processing():
		print("A request is already processing.")
		return

	var body = {
		"username": user_name,
		"item": item_name
	}
	var headers = PackedStringArray(["Content-Type: application/json"])
	var json_body = JSON.stringify(body)
	node.connect("request_completed", _on_purchase_response.bind(item_name, node), 0)
	node.request(url, headers, HTTPClient.METHOD_POST, json_body)

func _on_purchase_response(result, response_code, headers, body, item_name, node):	
	node.request_completed.disconnect(_on_purchase_response)
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		print(item_name + " purchased successfully.")
		ownership[item_name + "_owned"] = true
		equip_purchased_item(item_name, node)
	else:
		print("Failed to purchase " + item_name + ". Response code: ", response_code)


func equip_purchased_item(item_name, node):
	if node == music_request && item_name != equipped_items["track"]:
		equipped_items["track"] = item_name
		print("Equipped " + item_name)
	elif node == knife_request && item_name != equipped_items["knife"]:
		equipped_items["knife"] = item_name
		print("Equipped " + item_name)
	elif node == plate_request && item_name != equipped_items["plate"]:
		equipped_items["plate"] = item_name
		print("Equipped " + item_name)
	else:
		print("Unable to equip: " + item_name)


# Use if you want to equip an item, checks to see if the item is owned for you
func equip_item(item_name):
	if "knife" in item_name:
		if ownership[item_name + "_owned"]:
			equipped_items["knife"] = item_name
			set_active_knife(item_name)
			print(item_name + " knife equipped.")
		else:
			print("Knife not owned or does not exist.")
	elif "plate" in item_name:
		if ownership[item_name + "_owned"]:
			equipped_items["plate"] = item_name
			set_active_plate(item_name)
			print(item_name + " plate equipped.")
		else:
			print("Plate not owned or does not exist.")
	elif "track" in item_name:
		if ownership[item_name + "_owned"]:
			equipped_items["track"] = item_name
			set_active_track(item_name)
			print(item_name + " music track equipped.")
		else:
			print("Music track not owned or does not exist.")


func display_total_points(points):
	total_points = points
	emit_signal("points_updated", points)
	
func get_total_points():
	return total_points
	
func set_total_points(points):
	var json = JSON.new()
	if pts_request.is_processing():
		print("Request in progress")
		return
	var url = "http://localhost:8023/set_total_points"
	var body = {
		"username": user_name,
		"total_points": points
	}
	total_points = points # change this later, for now just testing if it works, should only work when the request is completed
	var headers = PackedStringArray(["Content-Type: application/json"])
	var json_body = json.stringify(body)
	pts_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	pts_request.connect("request_completed", _on_total_pts_req_complete)
	
func _on_total_pts_req_complete(result, response_code, headers, body):
	pts_request.disconnect("request_completed", _on_total_pts_req_complete)
	if response_code == 200:
		print("Successfully set total_points!")
	else:
		print("Hella womp womp energy over here :( error code: ", response_code)

func set_level_points(level_name, total_score, completed):
	var json = JSON.new()
	var http_request = get_node("HTTPRequest")
	if http_request.is_processing():
		print("A request is already processing.")
		return

	var url = "http://localhost:8023/set_level_points" 
	var body = {
		"username": user_name,
		"level": level_name,
		"points": total_score,
		"completed": completed
	}
	
	var headers = PackedStringArray(["Content-Type: application/json"])
	var json_body = json.stringify(body)
	http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
	http_request.connect("request_completed", _on_request_completed)

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		print("Level points updated successfully.")
	else:
		print("Failed to update level points. Response code:", response_code)
		
		
func fetch_ownership_details():
	if ownership_node.is_processing():
		print("A request is already processing.")
		return

	var url = "http://localhost:8023/get_ownership_details"
	var body = {"username": user_name}
	var headers = PackedStringArray(["Content-Type: application/json"])
	var json_body = JSON.stringify(body)
	ownership_node.request(url, headers, HTTPClient.METHOD_POST, json_body)

func _on_ownership_details_received(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var data = json.data
		print(data)
		ownership["green_knife_owned"] = data["data"]["green_knife_owned"]
		ownership["purple_knife_owned"] = data["data"]["purple_knife_owned"]
		ownership["pink_knife_owned"] = data["data"]["pink_knife_owned"]
		ownership["purple_plate_owned"] = data["data"]["purple_plate_owned"]
		ownership["blue_plate_owned"] = data["data"]["blue_plate_owned"]
		ownership["green_plate_owned"] = data["data"]["green_plate_owned"]
		print("Ownership details successfully updated.")
	else:
		print("Failed to fetch ownership details. Response code:", response_code)
		



