extends Node
class_name AchievementsHandler

### Member Variables and Dependencies -----
# signals 
signal safety_first_achieved
signal heard_the_scream_achieved
signal changed_the_universe_achieved
signal level_highscore_achieved
signal all_hihscores_achieved
signal slow_and_steady_achieved
signal infinite_jetpacker_achieved
signal shut_up_achieved
signal mileage_achieved
signal break_barriers_achieved
signal nothing_to_see_achieved

# enums
# constants
const TARGET_LAPS = 2
const TARGET_SCREAMS = 50
const TARGET_MILEAGE = 1000
const TARGET_BARRIERS = 500
const TARGET_LASER_DODGES = 250

# public variables
# achievements flags
var has_completed_safety_first: = false
var has_heard_the_scream: = false
var has_changed_the_univese: = false
# Slow and Steady Achievement
var has_completed_speedrun: = false 
# Infinie JetPacker Achievement
var has_completed_arcade: = false 
var has_any_highscore: = false
var has_all_highscores: = false

# stats
# Use this to determine HighScore Achievements
var has_highscore_on: = { 
	"1" : false,
	"2" : false,
	"3" : false,
	"4" : false,
	"5" : false,
	"6" : false,
	"7" : false,
	"8" : false,
	"9" : false,
	"10" : false,
	"11" : false,
	"12" : false,
}

# 'Ok, just shut up!' achievement
var screams_heard : = 0 
# 'That's some mileage points" achievement
var current_mileage : = 0 
# 'For a world without barriers' achievement
var current_barriers: = 0 
# for this one only dodged Lasers should count, Shield hits shouldn't count 
# 'Nothing to see here" achievement
var current_lasers: = 0 


# private variables
export var _version: = 1.0
export var _dir_path: = "user://"
export var _file_name: = ""

var _directory = Directory.new()
var _file = File.new()
var _full_path: = ""
var _serialized_data = {}
var _base_serialized_data = {}

### ---------------------------------------


### Built in Engine Methods ---------------
func _ready():
	_full_path = _dir_path.plus_file(_file_name)
	_base_serialized_data = _build_serialized_data()
	check_savefile()

### ---------------------------------------


### Public Methods ------------------------
func check_savefile():
	if not _directory.dir_exists(_dir_path):
		_directory.make_dir_recursive(_dir_path)
	
	if not _file.file_exists(_full_path):
		reset_savefile()
	
	read()


func reset_savefile():
	if not _serialized_data.empty():
		_translate_serialized_data(_base_serialized_data)
	save()


func save() -> void:
	_serialized_data = _build_serialized_data()
	var error = _file.open(_full_path,File.WRITE)
	if error != OK:
		_push_reading_file_error(error)
		return
	
	_file.store_var(_serialized_data)
	_file.close()


func read() -> void:
	var error = _file.open(_full_path,File.READ)
	if error != OK:
		_push_reading_file_error(error)
		return
	
	var old_settings = _file.get_var()
	
	if old_settings.has("version") and old_settings["version"] >= _version:
		_serialized_data = old_settings
	else:
		push_error("Missing Methods to convert old save data")
		assert(false)
	
	_file.close()
	
	_translate_serialized_data(_serialized_data)
	if OS.is_debug_build():
		printraw(var2str(_serialized_data))
		printraw("\n")


# Bellow Here things would go into the extended script if you change this to extend a Futur BaseSaveFile
func set_arcade_laps_achievement(num_of_laps: int) -> void:
	if has_completed_arcade:
		return
	elif num_of_laps >= TARGET_LAPS:
		has_completed_arcade = true
		save()


func set_highscore_achievements() -> void:
	has_any_highscore = _has_at_least_one_highscore()
	if has_any_highscore:
		emit_signal("level_highscore_achieved")
	
	has_all_highscores = _has_all_highscores()
	if has_all_highscores:
		emit_signal("all_hihscores_achieved")
	
	save()


func has_heard_enough_screams() -> bool:
	return screams_heard >= TARGET_SCREAMS


func has_enough_mileage() -> bool:
	return current_mileage >= TARGET_MILEAGE


func has_enough_broken_barriers() -> bool:
	return current_barriers >= TARGET_BARRIERS


func has_enough_laser_dodges() -> bool:
	return current_lasers >= TARGET_LASER_DODGES

### ---------------------------------------


### Private Methods -----------------------
func _push_reading_file_error(error) -> void:
	push_error("Error while reading %s: %s"%[_file_name, error])
	assert(false)

func _build_serialized_data() -> Dictionary:
	#This should be a 'virtual' function if you turn this into a BaseSaveFile class
	var settings: = {}
	settings["version"] = _version
	
	settings["has_completed_safety_first"] = has_completed_safety_first
	settings["has_completed_arcade"] = has_completed_arcade
	settings["has_changed_the_univese"] = has_changed_the_univese
	settings["has_completed_speedrun"] = has_completed_speedrun
	settings["has_completed_arcade"] = has_completed_arcade
	settings["screams_heard"] = screams_heard
	settings["current_mileage"] = current_mileage
	settings["current_barriers"] = current_barriers
	settings["current_lasers"] = current_lasers
	
	settings["has_highscore_on"] = var2str(has_highscore_on)
	
	return settings


func _translate_serialized_data(data: Dictionary) -> void:
	#This should be a 'virtual' function if you turn this into a BaseSaveFile class
	has_completed_safety_first = data["has_completed_safety_first"]
	if has_completed_safety_first:
		emit_signal("safety_first_achieved")
	
	has_heard_the_scream = data["has_heard_the_scream"]
	if has_heard_the_scream:
		emit_signal("heard_the_scream_achieved")
	
	has_changed_the_univese = data["has_changed_the_univese"]
	if has_changed_the_univese:
		emit_signal("changed_the_universe_achieved")
	
	has_completed_speedrun = data["has_completed_speedrun"]
	if has_completed_speedrun:
		emit_signal("slow_and_steady_achieved")
	
	has_completed_arcade = data["has_completed_arcade"]
	if has_completed_arcade:
		emit_signal("infinite_jetpacker_achieved")
	
	screams_heard = data["screams_heard"]
	if has_heard_enough_screams():
		emit_signal("shut_up_achieved")
	
	current_mileage = data["current_mileage"]
	if has_enough_mileage():
		emit_signal("mileage_achieved")
	
	current_barriers = data["current_barriers"]
	if has_enough_broken_barriers():
		emit_signal("break_barriers_achieved")
	
	current_lasers = data["current_lasers"]
	if has_enough_laser_dodges():
		emit_signal("nothing_to_see_achieved")
	
	has_highscore_on = str2var(data["has_highscore_on"])
	set_highscore_achievements()


# Bellow Here things would go into the extended script if you change this to extend a Futur BaseSaveFile
func _get_highscore_count() -> int:
	var highscores_count = 0
	for level in has_highscore_on:
		if has_highscore_on[level]:
			highscores_count += 1
	return highscores_count


func _has_at_least_one_highscore() -> bool:
	return _get_highscore_count() > 0


func _has_all_highscores() -> bool:
	return _get_highscore_count() == has_highscore_on.size()

### ---------------------------------------
