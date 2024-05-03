extends Marker2D

@onready var label = get_node("Label")
var amount = 0

func _ready():
	label.set_text(str("+",amount))
	var tween = create_tween()
	# tween.tween_property(self, 'scale', Vector2(2,2),0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	# tween.tween_property(self, 'scale', Vector2(0.5,0.5),0.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, 'position', Vector2(self.position.x, self.position.y - 20), 1).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	await tween.finished
	queue_free()
	pass


