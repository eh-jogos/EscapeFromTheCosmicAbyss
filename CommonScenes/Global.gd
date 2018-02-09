extends Node

var savefile = File.new()
var savepath = "user://savegame.save"

var savedata = {
	"how to play": false,
	"highscore": 0,
}

func _ready():
	if not savefile.file_exists(savepath):
		save()
	read()

func save():
	savefile.open(savepath,File.WRITE)
	savefile.store_var(savedata)
	savefile.close()

func read():
	savefile.open(savepath,File.READ)
	savedata = savefile.get_var()
	savefile.close()

func update_highscore(points):
	savedata["highscore"] = points
	save()
