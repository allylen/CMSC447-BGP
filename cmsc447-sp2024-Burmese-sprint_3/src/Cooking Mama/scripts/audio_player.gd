extends AudioStreamPlayer

const TRACK_ONE = preload("res://music/MAIN.ogg")
const TRACK_TWO = preload("res://music/song_two.ogg")
const TRACK_THREE = preload("res://music/song_three.ogg")


func play_track(music: AudioStream, volume: float = 0.0):
	if stream == music:
		return  

	stream = music
	volume_db = volume
	play()


func stop_music():
	stop()


func play_equipped_track():
	var equipped_track_name = Global.equipped_items["track"]

	match equipped_track_name:
		"track_one":
			play_track(TRACK_ONE)
		"track_two":
			play_track(TRACK_TWO)
		"track_three":
			play_track(TRACK_THREE)
		_:
			print("No equipped track found or incorrect track name.")


func play_track_one():
	play_track(TRACK_ONE)

func play_track_two():
	play_track(TRACK_TWO)
	
func play_track_three():
	play_track(TRACK_THREE)
