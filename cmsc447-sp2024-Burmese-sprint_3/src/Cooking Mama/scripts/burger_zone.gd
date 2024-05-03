extends Marker2D

func _draw():
	draw_circle(Vector2.ZERO, 75, Color.SLATE_GRAY)

func select():
	var zones = get_tree().get_nodes_in_group("zones")
	for child in zones:
		child.modulate = Color.TRANSPARENT

func _on_burger_held():
	var zones = get_tree().get_nodes_in_group("zones")
	for child in zones:
		if (child != zones[0] && child != zones[-1]):
			child.modulate = Color8(44, 212, 86, 50)
