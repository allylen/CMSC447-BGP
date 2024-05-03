extends Control

var _is_paused: bool =  false:
	set = set_paused
	
func set_paused(value:bool) ->void:
	_is_paused = value
	get_tree().paused = _is_paused
	visible = _is_paused
	


