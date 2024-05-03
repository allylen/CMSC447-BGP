extends Label

var totalPoints = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	text = str(totalPoints)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func incr_points(amount):
	totalPoints += amount
	text = str(totalPoints)
