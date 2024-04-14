extends AudioStreamPlayer


const click_sfx = preload("res://assets/8bit Click.ogg")


func _play_sfx(sfx: AudioStream, volume = -8.0):
	stream = sfx
	volume_db = volume
	play()
	
func play_sfx():
	_play_sfx(click_sfx)
