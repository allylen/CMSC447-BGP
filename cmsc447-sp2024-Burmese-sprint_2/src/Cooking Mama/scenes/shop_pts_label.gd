extends Label

func _ready():
	#Connect global signal points_updated to script to ensure this is called whenever total_points is updated.
	Global.connect("points_updated", _on_points_updated)


func _on_points_updated(new_points):
	self.text = str(new_points)
