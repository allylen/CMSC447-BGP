extends Marker2D

func _draw():
	draw_circle(Vector2.ZERO, 75, Color.TRANSPARENT)

func select():
	for child in get_tree().get_nodes_in_group("zones"):
		child.deselect()
	modulate = Color.TRANSPARENT

func deselect():
	modulate = Color.LIGHT_GRAY
