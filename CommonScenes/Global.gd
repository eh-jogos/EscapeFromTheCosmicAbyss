extends Node

var savefile = File.new()
var savepath = "user://savegame.save"
var version = 0.3

var savedata = {
	"version" : 0.3,
	"fullscreen" : true,
	"how to play": false,
	"highscore": 0,
}

func _ready():
	if not savefile.file_exists(savepath):
		save()
	
	read()
	
	if savedata.has("fullscreen"):
		OS.set_window_fullscreen(savedata["fullscreen"])
	else:
		print("NO FULLSCREEN OPTION ON SAVE")


func save():
	savefile.open(savepath,File.WRITE)
	savefile.store_var(savedata)
	savefile.close()

func read():
	savefile.open(savepath,File.READ)
	var old_save = savefile.get_var()
	if old_save.has("version"):
		savedata = old_save
		savefile.close()
	else:
		#print("SAVE ERROR")
		savedata["highscore"] = old_save["highscore"]
		savefile.close()
		
		save()

func update_highscore(points):
	savedata["highscore"] = points
	save()

func update_fullscreen(option):
	savedata["fullscreen"] = option
	save()
