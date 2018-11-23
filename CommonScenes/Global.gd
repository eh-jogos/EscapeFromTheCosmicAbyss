extends Node

var savefile = File.new()
var savepath = "user://savegame.save"
var version = 0.54

var savedata = {
	"version" : version,
	"options": {
		"fullscreen": true,
		"track": "2",
		"bgm volume": 60
	},
	"story": {
		"highscore": 0,
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
	"state": {
		"game mode" : "story",
		"sub-mode": "select level",
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

func update_story_highscore(points):
	savedata["story"]["highscore"] = points
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
	pass

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