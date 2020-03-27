extends Node

signal update_main_menu

const DEFAULT_SILHOUETTE_COLOR = Color(0.019608,0.078431,0.070588)
const DEFAULT_ENEMY_COLOR = Color(0.12549,0.392157,0.356863)
const DEFAULT_EYE_COLOR = Color(1,1,1,1)
const DEFAULT_EYE_CHARGE1_COLOR = Color(1,1,1,1)
const DEFAULT_EYE_CHARGE2_COLOR = Color(1,1,1,1)
const DEFAULT_EYE_CHARGE3_COLOR = Color(1,1,1,1)
const DEFAULT_ENEMY_LASER_COLOR = Color(1,1,1,1)


var savefile = File.new()
var savepath = "user://savegame.save"
var savedata = {}
var version = 0.63

var is_retry = false

#total sum of points that can be distributed in the player build in the base savedata
var base_stats = 15
var max_upgrade_level = 40
var base_upgrade = 30

var base_savedata = {
	"version" : version,
	"options": {
		"fullscreen": true,
		"track": "2",
		"bgm volume": 60
	},
	"story": {
		"highscore": [
				0, #0
				25, #1
				38, #2
				60, #3
				85, #4
				120, #5
				130, #6
				110, #7
				199, #8
				90, #9
				220, #10
				175, #11
				380, #12
		],
		"cooldown": 0,
		"initial ammo": 0,
		"initial shield": 0,
		"initial speed": 4.0,
		"max speed": 11.0,
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
		"upgrade points": 15,
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
}

func check_savefile():
	if not savefile.file_exists(savepath):
		reset_savefile()
	
	read()
	
	if savedata.has("options") and savedata["options"].has("fullscreen"):
		OS.set_window_fullscreen(savedata["options"]["fullscreen"])
	else:
		print("NO FULLSCREEN OPTION ON SAVE")
	
	print(savedata)

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
	if old_save.has("version") and old_save["version"] >= version:
		savedata = old_save
		savefile.close()
	else:
		#print("SAVE ERROR")
		if old_save.has("version") and old_save["version"] < version:
			savedata["story"]["cooldown"] = old_save["story"]["cooldown"]
			savedata["story"]["initial ammo"] = old_save["story"]["initial ammo"]
			savedata["story"]["initial shield"] = old_save["story"]["initial shield"]
			savedata["story"]["initial speed"] = old_save["story"]["initial speed"]
			savedata["story"]["max speed"] = old_save["story"]["max speed"]
			savedata["story"]["laser strength"] = old_save["story"]["laser duration"]
			savedata["story"]["upgrade points"] = old_save["story"]["upgrade points"]
			
			savedata["options"]["fullscreen"] = old_save["options"]["fullscreen"]
			savedata["options"]["track"] = old_save["options"]["track"]
			savedata["options"]["bgm volume"] = old_save["options"]["bgm volume"]
		elif old_save.has("version") and old_save["version"] <= 0.62:
			savedata["story"]["cooldown"] = old_save["story"]["cooldown"]
			savedata["story"]["initial ammo"] = old_save["story"]["initial ammo"]
			savedata["story"]["initial shield"] = old_save["story"]["initial shield"]
			savedata["story"]["initial speed"] = old_save["story"]["initial speed"]
			savedata["story"]["max speed"] = old_save["story"]["max speed"]
			savedata["story"]["laser duration"] = old_save["story"]["laser duration"]
			savedata["story"]["upgrade points"] = old_save["story"]["upgrade points"]
			
			savedata["options"]["fullscreen"] = old_save["options"]["fullscreen"]
			savedata["options"]["track"] = old_save["options"]["track"]
			savedata["options"]["bgm volume"] = old_save["options"]["bgm volume"]
		elif old_save.has("version") and old_save["version"] <= 0.34:
			savedata["options"]["fullscreen"] = old_save["options"]["fullscreen"]
			savedata["options"]["track"] = old_save["options"]["track"]
			savedata["options"]["bgm volume"] = old_save["options"]["bgm volume"]
		
		savefile.close()
		
		save()

func update_highscore(game_mode, points):
	if game_mode == "story":
		var index = savedata[game_mode]["current level"]
		savedata[game_mode]["highscore"][index] = points
	elif game_mode == "arcade" or game_mode == "speedrun":
		savedata[game_mode]["highscore"] = points
	else:
		print("ERROR SAVING HIGHSCORE | Invalid game_mode: %s"%[game_mode]) 
	save()

func update_hightime(time_duration):
	savedata["speedrun"]["hightime"] = time_duration
	save()

func update_highlaps(total_laps):
	savedata["arcade"]["highlaps"] = total_laps
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

func reset_story_progress():
	savedata["story"]["highscore"] = [
			0, #0
			25, #1
			38, #2
			60, #3
			85, #4
			120, #5
			130, #6
			110, #7
			199, #8
			90, #9
			220, #10
			175, #11
			380, #12
	]
	
	savedata["story"]["cooldown"] = 0
	savedata["story"]["initial ammo"] = 0
	savedata["story"]["initial shield"] = 0
	savedata["story"]["initial speed"] = 4.0
	savedata["story"]["max speed"] = 11.0
	savedata["story"]["laser strength"] = 0
	savedata["story"]["upgrade level"] = 1
	savedata["story"]["next upgrade"] = base_upgrade
	savedata["story"]["upgrade points"] = 0
	savedata["story"]["levels unlocked"] = 0
	savedata["story"]["current level"] = 0
	savedata["story"]["last unlock"] = 0
	savedata["story"]["tutorial beaten"] = false

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