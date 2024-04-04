extends AudioStreamPlayer


const menu_music = preload("res://music/MAIN.ogg")


func _play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return
	
	stream = music
	volume_db = volume
	play()
	
	
func play_menu_music():
	_play_music(menu_music)
