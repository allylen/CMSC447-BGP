extends AudioStreamPlayer


const track_one = preload("res://music/MAIN.ogg")




func _play_track_one(music: AudioStream, volume = -100.0):
	if stream == music:
		return
	
	stream = music
	volume_db = volume
	play()
	
func _play_track_two(music: AudioStream, volume = 0.0):
	pass

func _play_track_three(music: AudioStream, volume = 0.0):
	pass
	
func _stop_music(music: AudioStream, volume = 0.0):
	volume_db = volume
	stop()

func stop_music():
	_stop_music(track_one)
	
	


func play_track_one():
	_play_track_one(track_one)

func play_track_two():
	pass
	
func play_track_three():
	pass
