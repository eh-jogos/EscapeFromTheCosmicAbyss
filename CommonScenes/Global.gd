extends Node

# warning-ignore:unused_signal
signal update_main_menu
# warning-ignore:unused_signal
signal update_invincibility
# warning-ignore:unused_signal
signal barrier_tentacle_killed
# warning-ignore:unused_signal
signal shield_energy_updated_to(energy)

# Color Menu Signals
# warning-ignore:unused_signal
signal page_updated(first_button, last_button)
# warning-ignore:unused_signal
signal navigated_to_right
# warning-ignore:unused_signal
signal navigated_to_left
# warning-ignore:unused_signal
signal reset_color_pickers
# warning-ignore:unused_signal
signal color_picker_opened
# warning-ignore:unused_signal
signal color_picker_closed

#Achievements Menu Signals
# warning-ignore:unused_signal
signal achievement_info_sent(title, description)


const DEFAULT_SILHOUETTE_COLOR = Color("1f122d") #Color("041411") #OR Color("1f122d")
const DEFAULT_BODY_COLOR = Color("1f645b") 
const DEFAULT_EYE_COLOR = Color("00ffc3")
const DEFAULT_EYE_WARNING_COLOR1 = Color("c7ff00")
const DEFAULT_EYE_WARNING_COLOR2 = Color("ff8300")
const DEFAULT_EYE_WARNING_COLOR3 = Color("ff0041")

const DEFAULT_ENEMY_LASER_OUTLINE = Color("c63836")
const DEFAULT_ENEMY_LASER_CENTER = Color("ffffff")

const DEFAULT_BOSS_IRIS_COLOR = Color("c63836")
const DEFAULT_BOSS_TEETH_COLOR = Color("00ffc3")
const DEFAULT_BOSS_GENGIVA_COLOR = Color("264f44")
const DEFAULT_BOSS_TONGUE_COLOR = Color("c63836")

const HIGHSCORE_LVL_1 = 25
const HIGHSCORE_LVL_2 = 38
const HIGHSCORE_LVL_3 = 60
const HIGHSCORE_LVL_4 = 85
const HIGHSCORE_LVL_5 = 120
const HIGHSCORE_LVL_6 = 130
const HIGHSCORE_LVL_7 = 110
const HIGHSCORE_LVL_8 = 175
const HIGHSCORE_LVL_9 = 120
const HIGHSCORE_LVL_10 = 220
const HIGHSCORE_LVL_11 = 175
const HIGHSCORE_LVL_12 = 340

var savefile = File.new()
var savepath = "user://savegame.save"
var savedata = {}
var version = 1.1

var is_invincible = false
var is_retry = false
var was_credits_called_from_extras = false
var was_ending_called_from_extras = false

#total sum of points that can be distributed in the player build in the base savedata
var base_stats = 15
var max_upgrade_level = 40
var base_upgrade = 30

var default_color_scheme: Dictionary = {
	"waves" : {
		"outline": DEFAULT_SILHOUETTE_COLOR,
		"body": DEFAULT_BODY_COLOR,
	},
	"tentacles" : {
		"outline": DEFAULT_SILHOUETTE_COLOR,
		"body": DEFAULT_BODY_COLOR,
	},
	"laser_eye": {
		"outline": DEFAULT_SILHOUETTE_COLOR,
		"body": DEFAULT_BODY_COLOR,
		"eye": DEFAULT_EYE_COLOR,
		"warning1": DEFAULT_EYE_WARNING_COLOR1,
		"warning2": DEFAULT_EYE_WARNING_COLOR2,
		"warning3": DEFAULT_EYE_WARNING_COLOR3,
		"laser_outline": DEFAULT_ENEMY_LASER_OUTLINE,
		"laser_core": DEFAULT_ENEMY_LASER_CENTER,
	},
	"bg_boss":{
		"eye": DEFAULT_EYE_COLOR,
		"iris": DEFAULT_BOSS_IRIS_COLOR,
		"mouth": DEFAULT_BOSS_GENGIVA_COLOR,
		"teeth": DEFAULT_BOSS_TEETH_COLOR,
	},
	"mid_bg_boss":{
		"outline": DEFAULT_SILHOUETTE_COLOR,
		"body": DEFAULT_BODY_COLOR,
		"teeth": DEFAULT_BOSS_TEETH_COLOR,
		"eye": DEFAULT_EYE_COLOR,
		"iris": DEFAULT_BOSS_IRIS_COLOR,
	},
	"final_boss":{
		"outline": DEFAULT_SILHOUETTE_COLOR,
		"body": DEFAULT_BODY_COLOR,
		"eye": DEFAULT_EYE_COLOR,
		"warning1": DEFAULT_EYE_WARNING_COLOR1,
		"warning2": DEFAULT_EYE_WARNING_COLOR2,
		"warning3": DEFAULT_EYE_WARNING_COLOR3,
		"iris": DEFAULT_BOSS_IRIS_COLOR,
		"tongue": DEFAULT_BOSS_TONGUE_COLOR,
		"teeth": DEFAULT_BOSS_TEETH_COLOR,
		"gengiva": DEFAULT_BOSS_GENGIVA_COLOR,
		"laser_outline": DEFAULT_ENEMY_LASER_OUTLINE,
		"laser_core": DEFAULT_ENEMY_LASER_CENTER,
	},
}

var base_savedata = {
	"version" : version,
	"options": {
		"fullscreen": true,
		"track": "2",
		"bgm volume": 50,
		"sfx volume": 50
	},
	"story": {
		"highscore": [
				0, #0
				HIGHSCORE_LVL_1, #1
				HIGHSCORE_LVL_2, #2
				HIGHSCORE_LVL_3, #3
				HIGHSCORE_LVL_4, #4
				HIGHSCORE_LVL_5, #5
				HIGHSCORE_LVL_6, #6
				HIGHSCORE_LVL_7, #7
				HIGHSCORE_LVL_8, #8
				HIGHSCORE_LVL_9, #9
				HIGHSCORE_LVL_10, #10
				HIGHSCORE_LVL_11, #11
				HIGHSCORE_LVL_12, #12
		],
		"cooldown": 1,
		"initial ammo": 0,
		"initial shield": 1,
		"initial speed": 4.0,
		"max speed": 9.0,
		"laser strength": 0,
		"upgrade level": 1,
		"next upgrade": base_upgrade,
		"upgrade points": 0,
		"levels unlocked": 0,
		"current level":0,
		"last unlock": 0,
		"story beaten": false,
		"tutorial beaten": false,
		},
	"arcade": {
		"highlaps": 0,
		"highscore": 0,
		"cooldown": 0,
		"initial ammo": 0,
		"initial shield": 0,
		"initial speed": 0,
		"max speed": 0,
		"laser strength": 0,
		"upgrade points": 0,
		},
	"speedrun": {
		"hightime": 0,
		"highscore": 0,
		"cooldown": 0,
		"initial ammo": 0,
		"initial shield": 0,
		"initial speed": 0,
		"max speed": 0,
		"laser strength": 0,
		"upgrade points": 0,
		},
	"state": {
		"game mode" : "test_mode",
		"sub-mode": "15",
	},
	"colors": {},
}

onready var achievements_handler: AchievementsHandler = $AchievementsHandler

func _ready():
	base_savedata.colors = default_color_scheme.duplicate(true)
	check_savefile()


func check_savefile():
	if not savefile.file_exists(savepath):
		reset_savefile()
	
	read()
	
	if savedata.has("options") and savedata["options"].has("fullscreen"):
		OS.set_window_fullscreen(savedata["options"]["fullscreen"])
	else:
		print("NO FULLSCREEN OPTION ON SAVE")
	
	if savedata.has("story"):
		if savedata["story"].has("highscore"):
			for index in range(1, savedata["story"]["highscore"].size()):
				var score = savedata["story"]["highscore"][index]
				var goal_score = get("HIGHSCORE_LVL_%s"%[index])
				if score > goal_score:
					achievements_handler.set_highscore_achieved_on(str(index))
			
			achievements_handler.save()


func reset_savefile():
	savedata = base_savedata
	save()


func save():
	savefile.open(savepath,File.WRITE)
	savefile.store_var(savedata)
	savefile.close()


func read():
	savefile.open(savepath,File.READ)
	var old_save = savefile.get_var()
	
	if old_save == null:
		savefile.close()
		reset_savefile()
	else:
		if old_save.has("version") and old_save["version"] >= 0.9191:
			savedata = old_save
			savefile.close()
	
	if OS.is_debug_build():
		printraw(var2str(savedata))
		printraw("\n")


func update_highscore(game_mode, points):
	if game_mode == "story":
		var index = savedata[game_mode]["current level"]
		savedata[game_mode]["highscore"][index] = points
		achievements_handler.set_highscore_achieved_on(index)
	elif game_mode == "arcade" or game_mode == "speedrun":
		savedata[game_mode]["highscore"] = points
	else:
		print("ERROR SAVING HIGHSCORE | Invalid game_mode: %s"%[game_mode]) 
	save()


func update_hightime(time_duration):
	savedata["speedrun"]["hightime"] = time_duration
	if not achievements_handler.has_completed_speedrun:
		achievements_handler.has_completed_speedrun = true
	save()


func update_highlaps(total_laps):
	savedata["arcade"]["highlaps"] = total_laps
	Global.achievements_handler.set_arcade_laps_achievement(total_laps)
	save()


func update_story_upgrade(points):
	savedata["story"]["upgrade points"] = points
	savedata["story"]["upgrade level"] += 1
	savedata["story"]["next upgrade"] = calculate_next_upgrade()
	save()


func calculate_next_upgrade():
	var next_upgrade = 0
	if savedata["story"]["upgrade level"] < max_upgrade_level:
		next_upgrade = savedata["story"]["upgrade level"] * 0.5 * base_upgrade
	return next_upgrade


func update_story_next_upgrade(countdown):
	savedata["story"]["next upgrade"] = countdown
	save()


func update_story_unlocks(level):
	savedata["story"]["levels unlocked"] = level
	if level >= 1:
		achievements_handler.has_completed_safety_first = true
		achievements_handler.save()
	save()


func update_story_last_unlock(level):
	savedata["story"]["last unlock"] = level
	save()


func set_current_story_level(level):
	savedata["story"]["current level"] = level
	set_game_mode("story","level selected")


func update_story_stats(cooldown, ammo, shield, i_speed, m_speed, laser, upgrade):
	savedata["story"]["cooldown"] = cooldown
	savedata["story"]["initial ammo"] = ammo
	savedata["story"]["initial shield"] = shield
	savedata["story"]["initial speed"] = i_speed
	savedata["story"]["max speed"] = m_speed
	savedata["story"]["laser strength"] = laser
	savedata["story"]["upgrade points"] = upgrade
	save()


func reset_category_progress(game_mode_dict):
	var game_mode = game_mode_dict["game mode"]
	var points = int(game_mode_dict["sub-mode"])
	
	savedata[game_mode]["cooldown"] = 0
	savedata[game_mode]["initial ammo"] = 0
	savedata[game_mode]["initial shield"] = 0
	savedata[game_mode]["initial speed"] = 0
	savedata[game_mode]["max speed"] = 0
	savedata[game_mode]["laser strength"] = 0
	savedata[game_mode]["upgrade points"] = points
	save()


func update_category_stats(game_mode, cooldown, ammo, shield, i_speed, m_speed, laser, upgrade):
	savedata[game_mode]["cooldown"] = cooldown
	savedata[game_mode]["initial ammo"] = ammo
	savedata[game_mode]["initial shield"] = shield
	savedata[game_mode]["initial speed"] = i_speed
	savedata[game_mode]["max speed"] = m_speed
	savedata[game_mode]["laser strength"] = laser
	savedata[game_mode]["upgrade points"] = upgrade
	save()


func update_option_fullscreen(option):
	savedata["options"]["fullscreen"] = option


func update_option_track(option):
	savedata["options"]["track"] = option


func update_option_bgmvolume(option):
	savedata["options"]["bgm volume"] = option


func update_option_sfxvolume(option):
	savedata["options"]["sfx volume"] = option


func set_game_mode(game_mode, category):
	savedata["state"]["game mode"] = game_mode
	savedata["state"]["sub-mode"] = category
	save()


func get_game_mode():
	return savedata["state"]


func tutorial_completed():
	savedata["story"]["tutorial beaten"] = true
	save()

func story_completed():
	savedata["story"]["story beaten"] = true
	save()


func is_tutorial_completed():
	return savedata["story"]["tutorial beaten"]


func is_story_completed():
	return savedata["story"]["story beaten"]


func reset_story_progress():
	savedata["story"]["highscore"] = [
			0, #0
			HIGHSCORE_LVL_1, #1
			HIGHSCORE_LVL_2, #2
			HIGHSCORE_LVL_3, #3
			HIGHSCORE_LVL_4, #4
			HIGHSCORE_LVL_5, #5
			HIGHSCORE_LVL_6, #6
			HIGHSCORE_LVL_7, #7
			HIGHSCORE_LVL_8, #8
			HIGHSCORE_LVL_9, #9
			HIGHSCORE_LVL_10, #10
			HIGHSCORE_LVL_11, #11
			HIGHSCORE_LVL_12, #12
	]
	
	savedata["story"]["cooldown"] = 1
	savedata["story"]["initial ammo"] = 0
	savedata["story"]["initial shield"] = 1
	savedata["story"]["initial speed"] = 4.0
	savedata["story"]["max speed"] = 9.0
	savedata["story"]["laser strength"] = 0
	savedata["story"]["upgrade level"] = 1
	savedata["story"]["next upgrade"] = base_upgrade
	savedata["story"]["upgrade points"] = 0
	savedata["story"]["levels unlocked"] = 0
	savedata["story"]["current level"] = 0
	savedata["story"]["last unlock"] = 0
	savedata["story"]["tutorial beaten"] = false


func reset_colors() -> void:
	savedata.colors = default_color_scheme.duplicate(true)


func quit_game() -> void:
	get_tree().quit()
