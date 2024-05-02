extends Label

# YONAS SET POINTSPLUS VARIABLE EQUAL TO PLAYERS CURRENT POINTS
var pointsPlus = 0

func _ready():
	# Initialize the label text
	text = ""

# Function to increment points
func increment_points(amount):
	# YONAS ADD AMOUNT TO PLAYERS POINTS
	pointsPlus += amount
	# display points according to player's performance
	if amount < 10:
		text = "Very bad! \n+" + str(amount)
	elif amount < 30:
		text = "Not good. \n+" + str(amount)
	elif amount < 60:
		text = "Okay. \n+" + str(amount)
	elif amount < 70:
		text = "Good. \n+" + str(amount)
	elif amount < 80:
		text = "Very good. \n+" + str(amount)
	elif amount < 90:
		text = "Great Job! \n+" + str(amount)
	else:
		text = "Excellent! \n+" + str(amount)
