extends Node

# === /Signals/ ===
signal points_updated(new_points)

# Is the user logged in?
var logged_in = false
var user_name = null

# Current Level Selected by the User
var level = 1 # do not set to any number less than 1 (for my sanity, pls :3)

# Sentinel Value used to trigger display of popup
var display_popup = false
var popup_text = ""

# Variables to check if tracks are unlocked

var track_one_owned = false
var track_two_owned = false
var track_three_owned = false 


# Current Sound Track selected by the user
# Can be:
# track_one
# track_two
# track_three
var sound_track = "track_one"


# Points for each level
var total_points = 0 : set = set_total_points, get = get_total_points

func set_total_points(points):
	total_points = points
	emit_signal("points_updated", points)
	
func get_total_points():
	return total_points


var level_one_total_points = 0
var level_two_total_points = 0
var level_three_total_points = 0


# Cosmetic choice 
var knife_sprite = null
var plate_sprite = null
