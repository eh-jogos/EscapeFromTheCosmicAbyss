extends Node

var bgm2 = preload("res://CommonScenes/SoundManager/bgm/Musique_2.ogg")
var bgm3 = preload("res://CommonScenes/SoundManager/bgm/Musique_electro.ogg")
var track_list = {
	"2" : bgm2,
	"electro" : bgm3
}
var track_offset

var bgm_stream
var bgm_preview
var sfx_list: Node

var bgm_bus: int = AudioServer.get_bus_index("Bgm")
var sfx_bus_ui: int = AudioServer.get_bus_index("UiSfx")
var sfx_bus_game: int = AudioServer.get_bus_index("GameSfx")

var initial_volume: int
var current_volume: int

func _ready():
	bgm_stream = self.get_node("BGMPlayer")
	bgm_preview = self.get_node("PreviewPlayer")
	sfx_list = self.get_node("UiSfx")
	
	track_offset = 0
	
	initial_volume = Global.savedata["options"]["bgm volume"]
	current_volume = Global.savedata["options"]["bgm volume"]


func reset_ui_bus_effects() -> void:
	if AudioServer.is_bus_effect_enabled(sfx_bus_ui, 0):
		AudioServer.set_bus_effect_enabled(sfx_bus_ui, 0, false)


func play_sfx(sfx_name: String, is_unique: = false, reset_effects: = true) -> void:
	if reset_effects:
		reset_ui_bus_effects()
	
	if sfx_list.has_node(sfx_name):
		var sfx: AudioStreamPlayer = sfx_list.get_node(sfx_name)
		sfx.play()
		
		if is_unique:
			var other_sfx_list: Array = sfx_list.get_children()
			other_sfx_list.erase(sfx)
			for other_sfx in other_sfx_list:
				other_sfx.stop()
	else:
		push_warning("There is no %s in UI Sfx List"%[sfx_name])


func play_sfx_with_reverb(sfx_name: String, is_unique: = false) -> void:
	AudioServer.set_bus_effect_enabled(sfx_bus_ui, 0, true)
	play_sfx(sfx_name, is_unique, false)


func play_bgm(chosen_track: String):
	var track = chosen_track
	var volume = float(Global.savedata["options"]["bgm volume"])
#	print("Track: %s | Volume: %s"%[track, volume])
	
	change_bgm_volume(volume)
	
	bgm_stream.set_stream(track_list[track])
	bgm_stream.play(track_offset)

func pause_bgm():
	if not bgm_stream.playing:
		bgm_stream.play(track_offset)
	else:
		track_offset = bgm_stream.get_playback_position()
		bgm_stream.stop()

func stop_bgm():
	bgm_stream.stop()

func change_bgm_track():
	var total_length = bgm_stream.stream.get_length()
	var position = bgm_stream.get_playback_position()
	var percent = position/total_length
	var track = Global.savedata["options"]["track"]
	
	bgm_stream.set_stream(track_list[track])
	
	total_length = bgm_stream.stream.get_length()
	track_offset = percent*total_length

func reset_track():
	track_offset = 0

func bgm_set_loop(boolean):
	bgm_stream.stream.set_loop(boolean)

func preview_bgm(track):
	var volume = float(Global.savedata["options"]["bgm volume"])/100
#	print("Track: %s | Volume: %s"%[track, volume])
	
	change_bgm_volume(volume)
	
	bgm_preview.set_stream(track_list[track])
	bgm_preview.play()

func preview_bgm_play():
	if not bgm_preview.is_playing():
		var track = "2"
		self.preview_bgm(track)

func stop_preview_bgm():
	bgm_preview.stop()

func change_bgm_volume(vol):
	current_volume = vol
	
	var vol_db = _get_volume_in_db(vol)
	AudioServer.set_bus_volume_db(bgm_bus, vol_db)


func change_sfx_volume(vol):
	current_volume = vol
	
	var vol_db = _get_volume_in_db(vol)
	AudioServer.set_bus_volume_db(sfx_bus_game, vol_db)
	AudioServer.set_bus_volume_db(sfx_bus_ui, vol_db)


func mute_game_sfx():
	AudioServer.set_bus_mute(sfx_bus_game, true)


func unmute_game_sfx():
	AudioServer.set_bus_mute(sfx_bus_game, false)


func fade_out_credits_bgm():
	initial_volume = Global.savedata["options"]["bgm volume"]
	var tween = $Tween
	
	tween.interpolate_method(self, "change_bgm_volume", initial_volume, 0, 3, 
			Tween.TRANS_BACK, Tween.EASE_IN)
	tween.start()


func fade_out_start():
	initial_volume = Global.savedata["options"]["bgm volume"]
	var tween = $Tween
	
	tween.interpolate_method(self, "change_bgm_volume", initial_volume, initial_volume-20, 1, 
			Tween.TRANS_BACK, Tween.EASE_IN)
	tween.start()


func fade_in_start():
	var tween = $Tween
	if tween.is_active():
		tween.remove_all()
	
	tween.interpolate_method(self, "change_bgm_volume", current_volume, initial_volume, 1, 
			Tween.TRANS_BACK, Tween.EASE_IN)
	tween.start()


func _get_volume_in_db(vol: int) -> float:
	var float_vol: float = vol * 0.01
	var volume_db: float = linear2db(float_vol)
	return volume_db
