extends Node

var level = {}
var level_info

func load_level(num):
	level_info = get_child(num)
	build_boss()
	build_beats()
	build_half_beats()
	return level

func build_boss():
	if level_info.boss["boss_level"]:
		pass
	elif level_info.boss["scream"]:
		level["boss_level"] = false
		pass
	else:
		level["boss_level"] = false
		level["boss_scream"] = false

func build_beats():
	level["beats"] = []
	for x in level_info.intro_beats:
		level["beats"].append(x)
	pass

func build_half_beats():
	level["half_beats"] = []
	for x in level_info.intro_halfs:
		level["half_beats"].append(x)
	pass