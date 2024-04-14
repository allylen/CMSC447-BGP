extends Node
@export var burger: PackedScene
@onready var cookTimer = $CookTimerAnimation
@onready var cookArrow = $CookTimerAnimation/CookTimerArrow
@onready var cookTimerBar = $CookTimerBar
@onready var cookTimer2 = $CookTimerAnimation2
@onready var cookArrow2 = $CookTimerAnimation2/CookTimerArrow
@onready var cookTimerBar2 = $CookTimerBar2

var curSide = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	var newBurger = burger.instantiate()
	cookArrow.hide() # Make it so the arrow only shows once the burger starts cooking
	cookTimerBar.hide() # Same with the bar for the timer
	cookArrow2.hide()
	cookTimerBar2.hide()
	newBurger.position = $Burger_Start.position
	add_child(newBurger)
	newBurger.tree_exited.connect(_on_burger_tree_exited)
	newBurger.startCooking.connect(_on_burger_start_cooking)
	newBurger.pauseCooking.connect(_on_burger_pause_cooking)
	newBurger.burgFlip.connect(_on_burger_flip)
	curSide = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_burger_tree_exited(): # When a burger is burnt/discarded, create a new one
	var newBurger = burger.instantiate()
	newBurger.position = $Burger_Start.position
	add_child(newBurger)
	newBurger.tree_exited.connect(_on_burger_tree_exited)
	newBurger.startCooking.connect(_on_burger_start_cooking)
	newBurger.pauseCooking.connect(_on_burger_pause_cooking)
	newBurger.burgFlip.connect(_on_burger_flip)
	cookArrow.hide()
	cookTimerBar.hide()
	cookArrow2.hide()
	cookTimerBar2.hide()
	curSide = 1

func _on_burger_start_cooking():
	cookTimer.play("RESET")
	cookTimer2.play("RESET")
	cookArrow.show()
	cookTimerBar.show()
	cookArrow2.show()
	cookTimerBar2.show()
	cookTimer.play("Arrow")

func _on_burger_pause_cooking():
	if (curSide == 1):
		cookTimer.pause()
	else:
		cookTimer2.pause()

func _on_burger_flip():
	if (curSide == 1):
		curSide = 2
		cookTimer.pause()
		cookTimer2.play("Arrow")
	else:
		curSide = 1
		cookTimer2.pause()
		cookTimer.play("Arrow")
	
