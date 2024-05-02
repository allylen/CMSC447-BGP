extends Node
@export var burger: PackedScene
@export var floating_score: PackedScene
@onready var cookTimer = $CookTimerAnimation
@onready var cookArrow = $CookTimerAnimation/CookTimerArrow
@onready var cookTimerBar = $CookTimerBar
@onready var cookTimer2 = $CookTimerAnimation2
@onready var cookArrow2 = $CookTimerAnimation2/CookTimerArrow
@onready var cookTimerBar2 = $CookTimerBar2
@onready var curScoreText = $"Current Score"
@onready var numBurgsText = $"Burgers Cooked"
@onready var timeRemaining = $TimeRemaining
@onready var gameTimer = $GameTimer

var level = Global.level
var curSide = 1
var curScore = 0
var num_Burgers_Cooked = 0
var gameTime = 20 * (4 - level)
# Called when the node enters the scene tree for the first time.
func _ready():
	gameTimer.wait_time = gameTime
	gameTimer.start()
	var newBurger = burger.instantiate()
	cookTimer.speed_scale = 1 + (0.5 * (level - 1)) # Speed increases by 0.5 for each level
	cookTimer2.speed_scale = 1 + (0.5 * (level - 1))
	cookArrow.hide() # Make it so the arrow only shows once the burger starts cooking
	cookTimerBar.hide() # Same with the bar for the timer
	cookArrow2.hide()
	cookTimerBar2.hide()
	newBurger.position = $Burger_Start.position
	add_child(newBurger)
	newBurger.tree_exited.connect(_on_burger_tree_exited)
	newBurger.startCooking.connect(_on_burger_start_cooking)
	newBurger.pauseCooking.connect(_on_burger_pause_cooking)
	newBurger.resumeCooking.connect(_on_burger_resume_cooking)
	newBurger.burgFlip.connect(_on_burger_flip)
	newBurger.burgFinish.connect(_on_burger_finish)
	curSide = 1
	for child in $Grill_Zone1.get_tree().get_nodes_in_group("zones"):
		newBurger.burgHeld.connect(child._on_burger_held)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	timeRemaining.text = str(floor(gameTimer.time_left)) # Updates the timer on-screen


func _on_burger_tree_exited(): # When a burger is burnt/discarded, create a new one
	var newBurger = burger.instantiate()
	newBurger.position = $Burger_Start.position
	add_child(newBurger)
	newBurger.tree_exited.connect(_on_burger_tree_exited)
	newBurger.startCooking.connect(_on_burger_start_cooking)
	newBurger.pauseCooking.connect(_on_burger_pause_cooking)
	newBurger.resumeCooking.connect(_on_burger_resume_cooking)
	newBurger.burgFlip.connect(_on_burger_flip)
	newBurger.burgFinish.connect(_on_burger_finish)
	cookArrow.hide()
	cookTimerBar.hide()
	cookArrow2.hide()
	cookTimerBar2.hide()
	curSide = 1

func _on_burger_start_cooking(): # Called when a burger is placed on the grill for the first time
	cookArrow.show()
	cookTimerBar.show()
	cookArrow2.show()
	cookTimerBar2.show()
	cookTimer.play("RESET")
	cookTimer2.play("RESET")
	cookTimer.play("Arrow")

func _on_burger_pause_cooking(): # Called when a burger is picked up from the grill
	if (curSide == 1):
		cookTimer.pause()
	else:
		cookTimer2.pause()

func _on_burger_resume_cooking(): # Called when a burger is placed on the grill (after being picked up and cooked some amount)
	if (curSide == 1):
		cookTimer.play("Arrow")
	else:
		cookTimer2.play("Arrow")

func _on_burger_flip(): # When the flip key (spacebar) is pressed
	if (curSide == 1):
		curSide = 2
		cookTimer.pause()
		cookTimer2.play("Arrow")
	else:
		curSide = 1
		cookTimer2.pause()
		cookTimer.play("Arrow")
	
func _on_burger_finish(side1, side2): # When the burger is moved to the end zone (Finished cooking)
	var tempScore = 0
	if level == 1:
		tempScore = int((5 - abs(5 - side1)) + (5 - abs(5 - side2)) * 10)
	elif level == 2:
		tempScore = int((3.75 - abs(3.75 - side1)) + (3.75 - abs(3.75 - side2)) * 20)
	elif level == 3:
		tempScore = int((2.5 - abs(2.5 - side1)) + (2.5 - abs(2.5 - side2)) * 40)
	curScore += tempScore # Add the current burger's score to the total score
	num_Burgers_Cooked += 1 # Increment the number of burgers that have been cooked
	var scoreText = floating_score.instantiate() # Create the floating score text popup
	scoreText.amount = tempScore
	scoreText.position = $Burger_End.position
	add_child(scoreText)
	curScoreText.text = str(curScore) # Set the onscreen score text
	numBurgsText.text = str(num_Burgers_Cooked) # Set the onscreen burg number
	


func _on_game_timer_timeout(): # When the timer reaches 0
	Global.stage_two_total_points = curScore # set the score for stage two of the level
	get_tree().change_scene_to_file("res://scenes/select_level.tscn") # Replace this with the assembly scene when added
	# Note for Yonas - at this point, can send the score and number of burgers to database (And feel free to adjust the multiplier on the score for balancing purposes)
	
