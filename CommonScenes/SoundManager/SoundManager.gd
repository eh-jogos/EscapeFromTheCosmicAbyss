extends Node

var bgm2 = preload("res://CommonScenes/SoundManager/bgm/Musique_2.ogg")
var bgm3 = preload("res://CommonScenes/SoundManager/bgm/Musique_electro.ogg")
var track_list = {
	"2" : bgm2,
	"electro" : bgm3
}
var track_offset = 0

var bgm_bus: int = AudioServer.get_bus_index("Bgm")
var sfx_bus_ui: int = AudioServer.get_bus_index("UiSfx")
var sfx_bus_game: int = AudioServer.get_bus_index("GameSfx")

var initial_volume: int
var current_volume: int
var is_faded_out: bool = false

@onready var bgm_stream := $BGMPlayer as AudioStreamPlayer
@onready var bgm_preview := $PreviewPlayer as AudioStreamPlayer
@onready var sfx_dict := {}

var _tween_bgm: Tween

func _ready():
	for node in $UiSfx.get_children():
		sfx_dict[node.name] = node
	
	initial_volume = Global.savedata["options"]["bgm volume"]
	current_volume = initial_volume
	
	change_bgm_volume(initial_volume)
	change_sfx_volume(Global.savedata["options"]["sfx volume"])


func reset_ui_bus_effects() -> void:
	if AudioServer.is_bus_effect_enabled(sfx_bus_ui, 0):
		AudioServer.set_bus_effect_enabled(sfx_bus_ui, 0, false)


func play_sfx(sfx_name: String, is_unique: = false, reset_effects: = true) -> void:
	if reset_effects:
		reset_ui_bus_effects()
	
	if sfx_name in sfx_dict:
		var sfx: AudioStreamPlayer = sfx_dict[sfx_name]
		sfx.play()
		
		if is_unique:
			for other in sfx_dict:
				if other == sfx_name:
					continue
				sfx_dict[other].stop()
	else:
		push_warning("There is no %s in UI Sfx List"%[sfx_name])


func play_sfx_with_reverb(sfx_name: String, is_unique: = false) -> void:
	AudioServer.set_bus_effect_enabled(sfx_bus_ui, 0, true)
	play_sfx(sfx_name, is_unique, false)


func play_bgm(chosen_track: String):
	var track = chosen_track
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
	# TODO - Refactor to save audio volume valumes in float and use then in float througout here
	var volume = float(Global.savedata["options"]["bgm volume"])/100
#	print("Track: %s | Volume: %s"%[track, volume])
	
	change_bgm_volume(volume)
	
	bgm_preview.set_stream(track_list[track])
	bgm_preview.play()


func preview_bgm_play():
	if not bgm_preview.is_playing():
		var track = "2"
		preview_bgm(track)


func stop_preview_bgm():
	bgm_preview.stop()


# TODO - Refactor to save audio volume valumes in float and use then in float througout here
func change_bgm_volume(vol: int):
	current_volume = vol
	
	var vol_db = _get_volume_in_db(vol)
	AudioServer.set_bus_volume_db(bgm_bus, vol_db)


# TODO - Refactor to save audio volume valumes in float and use then in float througout here
func change_sfx_volume(vol: int):
	current_volume = vol
	#print("Changing SFX volume")
	var vol_db = _get_volume_in_db(vol)
	AudioServer.set_bus_volume_db(sfx_bus_game, vol_db)
	AudioServer.set_bus_volume_db(sfx_bus_ui, vol_db)


func mute_game_sfx():
	AudioServer.set_bus_mute(sfx_bus_game, true)


func unmute_game_sfx():
	AudioServer.set_bus_mute(sfx_bus_game, false)


func fade_out_credits_bgm():
	initial_volume = Global.savedata["options"]["bgm volume"]
	if _tween_bgm:
		_tween_bgm.kill()
	_tween_bgm = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_tween_bgm.tween_method(change_bgm_volume, initial_volume, 0, 3.0)
	_tween_bgm.start()


func fade_out_start(shoul_be_immediate: = false):
	is_faded_out = true
	initial_volume = Global.savedata["options"]["bgm volume"]
	var target_volume = max(initial_volume-30, 0)
	
	if shoul_be_immediate:
		change_bgm_volume(target_volume)
	else:
		if _tween_bgm:
			_tween_bgm.kill()
		_tween_bgm = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		_tween_bgm.tween_method(change_bgm_volume, initial_volume, target_volume, 0.5)
		_tween_bgm.start()


func fade_in_start(shoul_be_immediate: = false):
	is_faded_out = false
	initial_volume = Global.savedata["options"]["bgm volume"]
	
	if shoul_be_immediate:
		change_bgm_volume(initial_volume)
	else:
		var current_volume_db := AudioServer.get_bus_volume_db(bgm_bus)
		# TODO - Refactor to save audio volume valumes in float and use then in float througout here
		current_volume = int(db_to_linear(current_volume_db) * 100)
		if _tween_bgm:
			_tween_bgm.kill()
		_tween_bgm = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		_tween_bgm.tween_method(change_bgm_volume, current_volume, initial_volume, 0.5)
		_tween_bgm.start()

# TODO - Refactor to save audio volume valumes in float and use then in float througout here
func _get_volume_in_db(vol: int) -> float:
	# TODO - Refactor to save audio volume valumes in float and use then in float througout here
	var float_vol: float = vol * 0.01
	#print("Float Vol: %s"%[float_vol])
	var volume_db: float = linear_to_db(float_vol)
	return volume_db
