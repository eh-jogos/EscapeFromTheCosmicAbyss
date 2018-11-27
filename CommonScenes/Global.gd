extends Node

var savefile = File.new()
var savepath = "user://savegame.save"
var version = 0.56

var savedata = {
	"version" : version,
	"options": {
		"fullscreen": true,
		"track": "2",
		"bgm volume": 60
	},
	"story": {
		"highscore": [
				0, #0
				0, #1
				0, #2
				0, #3
				0, #4
				0, #5
				0, #6
				0, #7
				0, #8
				0, #9
				0, #10
				0, #11
				0, #12
		],
		"cooldown": 0,
		"initial ammo": 0,
		"initial shield": 0,
		"initial speed": 4.0,
		"max speed": 11.0,
		"laser duration": 0,
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
		"laser duration": 0,
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
		"laser duration": 0,
		"upgrade points": 0,
		},
	"state": {
		"game mode" : "arcade",
		"sub-mode": "15",
	},
}

func _ready():
	if not savefile.file_exists(savepath):
		save()
	
	read()
	
	if savedata.has("options") and savedata["options"].has("fullscreen"):
		OS.set_window_fullscreen(savedata["options"]["fullscreen"])
	else:
		print("NO FULLSCREEN OPTION ON SAVE")
	
	print(savedata)


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
			savedata["story"]["highscore"] = old_save["story"]["highscore"]
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
			savedata["story"]["highscore"] = old_save["highscore"]
			savedata["options"]["fullscreen"] = old_save["options"]["fullscreen"]
			savedata["options"]["track"] = old_save["options"]["track"]
			savedata["options"]["bgm volume"] = old_save["options"]["bgm volume"]
		else:
			savedata["story"]["highscore"] = old_save["highscore"]
		
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
	savedata["story"]["laser duration"] = laser
	savedata["story"]["upgrade points"] = upgrade
	save()

func reset_story_progress():
	savedata["story"]["highscore"] = 0
	savedata["story"]["cooldown"] = 0
	savedata["story"]["initial ammo"] = 0
	savedata["story"]["initial shield"] = 0
	savedata["story"]["initial speed"] = 4.0
	savedata["story"]["max speed"] = 11.0
	savedata["story"]["laser duration"] = 0
	savedata["story"]["upgrade points"] = 0
	savedata["story"]["levels unlocked"] = 0
	savedata["story"]["current level"] = 0
	savedata["story"]["last unlock"] = 0

func reset_category_progress(game_mode_dict):
	var game_mode = game_mode_dict["game mode"]
	var points = int(game_mode_dict["sub-mode"])
	
	savedata[game_mode]["cooldown"] = 0
	savedata[game_mode]["initial ammo"] = 0
	savedata[game_mode]["initial shield"] = 0
	savedata[game_mode]["initial speed"] = 0
	savedata[game_mode]["max speed"] = 0
	savedata[game_mode]["laser duration"] = 0
	savedata[game_mode]["upgrade points"] = points
	save()

func update_category_stats(game_mode, cooldown, ammo, shield, i_speed, m_speed, laser, upgrade):
	savedata[game_mode]["cooldown"] = cooldown
	savedata[game_mode]["initial ammo"] = ammo
	savedata[game_mode]["initial shield"] = shield
	savedata[game_mode]["initial speed"] = i_speed
	savedata[game_mode]["max speed"] = m_speed
	savedata[game_mode]["laser duration"] = laser
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