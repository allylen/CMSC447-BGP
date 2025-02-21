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
var plate = Global.equipped_items["plate"]
var curSide = 1
var curScore = 0
var num_Burgers_Cooked = 0
var gameTime = 20 * (4 - level)
# Called when the node enters the scene tree for the first time.
func _ready():
	if plate == "blue_plate":
		$StartPlate.texture = load("res://assets/Finalized Art/Brian/plate sprite blue.png")
	elif plate == "purple_plate":
		$StartPlate.texture = load("res://assets/Finalized Art/Brian/plate pink.png")
	elif plate == "green_plate":
		$StartPlate.texture = load("res://assets/Shop/plate sprite green.png")
	gameTimer.wait_time = gameTime
	gameTimer.start()
	var newBurger = burger.instantiate()
	if level == 1:
		cookTimer.speed_scale = 1 # 10 sec
		cookTimer2.speed_scale = 1
	elif level == 2:
		cookTimer.speed_scale = 1.33333 # 7.5 sec (approx)
		cookTimer2.speed_scale = 1.33333
	elif level == 3:
		cookTimer.speed_scale = 2 # 5 sec
		cookTimer2.speed_scale = 2
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
	var scoreScale = 10 + (5 * (level - 1))
	var tempScore = int(((5 - abs(5 - side1)) + (5 - abs(5 - side2))) * scoreScale)
	curScore += tempScore # Add the current burger's score to the total score
	num_Burgers_Cooked += 1 # Increment the number of burgers that have been cooked
	var scoreText = floating_score.instantiate() # Create the floating score text popup
	scoreText.amount = tempScore
	scoreText.position = $Burger_End.position
	add_child(scoreText)
	curScoreText.text = str(curScore) # Set the onscreen score text
	numBurgsText.text = str(num_Burgers_Cooked) # Set the onscreen burg number
	


func _on_game_timer_timeout(): # When the timer reaches 0
	if Global.level == 1:
		Global.level_one_total_points += curScore
	elif Global.level == 2:
		Global.level_two_total_points += curScore
	elif Global.level == 3:
		Global.level_three_total_points += curScore
	Global.total_points += curScore
	Global.set_total_points(Global.total_points)
	if level == 1:
		get_tree().change_scene_to_file("res://scenes/assemblingLevel1/moveBun.tscn") # If level 1, go to the level 1 version of assembly scene
	elif level == 2:
		get_tree().change_scene_to_file("res://scenes/assemblingLevel2/moveBun.tscn") # If level 2, go to the level 2 version of assembly scene
	elif level == 3:
		get_tree().change_scene_to_file("res://scenes/assemblingLevel3/moveBun.tscn") # If level 3, go to the level 3 version of assembly scene
