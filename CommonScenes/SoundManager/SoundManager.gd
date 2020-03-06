extends Node

var bgm1 = preload("res://CommonScenes/SoundManager/bgm/Musique 1.ogg")
var bgm2 = preload("res://CommonScenes/SoundManager/bgm/Musique 2.ogg")
var bgm3 = preload("res://CommonScenes/SoundManager/bgm/Musique electro.ogg")
var track_list = {
	"1" : bgm1,
	"2" : bgm2,
	"electro" : bgm3
}
var track_offset

var bgm_stream
var bgm_preview
var sfx_player
var fade_out
var fade_in

var initial_volume

func _ready():
	bgm_stream = self.get_node("BGMPlayer")
	bgm_preview = self.get_node("PreviewPlayer")
	sfx_player = self.get_node("SfxPlayer")
	
	fade_out = self.get_node("FadeOutTimer")
	fade_in = self.get_node("FadeInTimer")
	
	track_offset = 0


func play_sfx(sfx_name, is_unique = false):
	sfx_player.play(sfx_name, is_unique)


func play_sfx_with_reverb(sfx_name, is_unique = false, reverb_size = SamplePlayer.REVERB_HALL, reverb_strenght = 0.5):
	sfx_player.set_reverb(sfx_player.play(sfx_name, is_unique), reverb_size, reverb_strenght)


func play_bgm():
	var track = Global.savedata["options"]["track"]
	var volume = float(Global.savedata["options"]["bgm volume"])/100
	print("Track: %s | Volume: %s"%[track, volume])
	
	bgm_stream.set_stream(track_list[track])
	bgm_stream.set_volume(volume)
	bgm_stream.play(track_offset)

func pause_bgm():
	if bgm_stream.is_paused():
		bgm_stream.set_paused(false)
		bgm_stream.play(track_offset)
	else:
		bgm_stream.set_paused(true)
		track_offset = bgm_stream.get_pos()

func stop_bgm():
	bgm_stream.stop()

func change_bgm_track():
	var total_length = bgm_stream.get_length()
	var position = bgm_stream.get_pos()
	var percent = position/total_length
	var track = Global.savedata["options"]["track"]
	
	bgm_stream.set_stream(track_list[track])
	
	total_length = bgm_stream.get_length()
	track_offset = percent*total_length

func reset_track():
	track_offset = 0

func bgm_set_loop(boolean):
	bgm_stream.set_loop(boolean)

func preview_bgm(track):
	var volume = float(Global.savedata["options"]["bgm volume"])/100
	print("Track: %s | Volume: %s"%[track, volume])
	
	bgm_preview.set_stream(track_list[track])
	bgm_preview.set_volume(volume)
	bgm_preview.play()

func preview_bgm_play():
	if not bgm_preview.is_playing():
		var track = Global.savedata["options"]["track"]
		self.preview_bgm(track)

func stop_preview_bgm():
	bgm_preview.stop()

func change_bgm_volume(vol):
	print("Vol: %s | Volume: %s"%[vol, float(vol)/100])	
	bgm_stream.set_volume(float(vol)/100)
	bgm_preview.set_volume(float(vol)/100)

func fade_out_start():
	if fade_in.is_active():
		fade_in_stop()
	initial_volume = Global.savedata["options"]["bgm volume"]*0.01
	fade_out.set_active(true)
	fade_out.start()
	
	print("Initial Volume: %s"%[initial_volume])

func fade_out_stop():
	fade_out.stop()
	fade_out.set_active(false)
	print("Stop Volume: %s"%[bgm_stream.get_volume()])

func fade_in_start():
	if fade_out.is_active():
		fade_out_stop()
	initial_volume = bgm_stream.get_volume()
	fade_in.set_active(true)
	fade_in.start()
	
	print("Initial Volume: %s"%[initial_volume])

func fade_in_stop():
	fade_in.stop()
	fade_in.set_active(false)
	print("Stop Volume: %s"%[bgm_stream.get_volume()])

func _on_FadeOutTimer_timeout():
	print("fade out!")
	var current_vol = bgm_stream.get_volume()
	current_vol -= 0.02
	
	if current_vol < 0:
		current_vol = 0
	
	if initial_volume - 0.3 >= 0:
		if current_vol > initial_volume - 0.3:
			bgm_stream.set_volume(current_vol)
		else:
			fade_out_stop()
	else:
		if current_vol > 0:
			bgm_stream.set_volume(current_vol)
		else:
			fade_out_stop()

func _on_FadeInTimer_timeout():
	print("fade in!")
	var current_vol = bgm_stream.get_volume()
	current_vol += 0.02
	
	if initial_volume + 0.3 <= Global.savedata["options"]["bgm volume"]*0.01:
		if current_vol < Global.savedata["options"]["bgm volume"]*0.01:
			bgm_stream.set_volume(current_vol)
		else:
			bgm_stream.set_volume(Global.savedata["options"]["bgm volume"]*0.01)
			fade_in_stop()
	else:
		if current_vol < Global.savedata["options"]["bgm volume"]*0.01:
			bgm_stream.set_volume(current_vol)
		else:
			bgm_stream.set_volume(Global.savedata["options"]["bgm volume"]*0.01)
			fade_in_stop()

