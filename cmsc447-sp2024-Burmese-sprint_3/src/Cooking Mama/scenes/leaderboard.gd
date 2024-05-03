extends Control

var http_request = HTTPRequest.new()
var leaderboard_container = VBoxContainer.new()

func _ready():
	add_child(http_request)
	http_request.connect("request_completed", _on_request_completed)
	http_request.request("http://localhost:8023/get_top_user_scores")

	# Configure leaderboard container
	leaderboard_container.size_flags_horizontal = SIZE_EXPAND_FILL
	leaderboard_container.size_flags_vertical = SIZE_EXPAND_FILL
	leaderboard_container.minimum_size = Vector2(1920, 1080)  # Set container size to match the game resolution
	leaderboard_container.alignment = BoxContainer.ALIGNMENT_CENTER # Center the content vertically
	add_child(leaderboard_container)

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.new()
		json.parse(body.get_string_from_utf8())
		var data = json.data
		if "success" in data:
			update_leaderboard(data["leaderboard"])
		else:
			show_error("No leaderboard data found.")
	else:
		show_error("Failed to fetch data: HTTP Code %s" % response_code)

func update_leaderboard(leaderboard):
	# Clear previous content
	for child in leaderboard_container.get_children():
		child.queue_free()

	for entry in leaderboard:
		var entry_container = HBoxContainer.new()
		entry_container.alignment = BoxContainer.ALIGNMENT_CENTER  # Center the content horizontally
		entry_container.add_constant_override("separation", 20)  # Add spacing between name and score

		var name_label = create_label(entry["name"])
		var score_label = create_label(str(entry["score"]))

		entry_container.add_child(name_label)
		entry_container.add_child(score_label)

		leaderboard_container.add_child(entry_container)

func create_label(text):
	var label = Label.new()
	label.text = text
	label.add_font_override("font_size", 24)  # Set the font size to 24
	label.add_constant_override("line_spacing", 10)
	return label

func show_error(message):
	print(message)
