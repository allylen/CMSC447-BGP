extends Label

var addPoints = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	text = ""


# Called every frame. 'delta' is the elapsed time since the previous frame.
func incr_points(amount):
	addPoints = amount
	if amount < 30:
		text = "Very bad! \n" + str(amount)
	elif amount < 50:
		text = "Bad! \n" + str(amount)
	elif amount < 70:
		text = "Decent! \n" + str(amount)
	elif amount < 80:
		text = "Good! \n" + str(amount)
	elif amount < 90:
		text = "Great! \n" + str(amount)
	else:
		text = "Amazing! \n" + str(amount)
