extends Node

var level = {}
var level_info

func load_level(num):
	level_info = get_child(num)
	level["title"] = level_info.level_title
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
	var obstacle_pool = []
	level["beats"] = []
	
	add_intro(level["beats"], level_info.intro_beats)
	obstacle_pool = build_obstacle_pool(level_info["beats"])
	build_random_level(level["beats"], obstacle_pool)
	
	level["beats"].append(level_info.end_beat)

func build_half_beats():
	var obstacle_pool = []
	level["half_beats"] = []
	
	add_intro(level["half_beats"], level_info.intro_halfs)
	obstacle_pool = build_obstacle_pool(level_info["half_beats"])
	build_random_level(level["half_beats"], obstacle_pool)


func add_intro(target_array, intro_array):
	for x in intro_array:
		target_array.append(x)

func build_obstacle_pool(base_array):
	var random_pool = []
	for key in base_array:
		if base_array[key] > 0:
			var value = key_translator(key)
			for x in range(base_array[key]):
				random_pool.append(value)
	return random_pool

func build_random_level(target_array, pool):
	for x in range(pool.size()):
		var random_integer = randi() % pool.size()
		target_array.append(pool[random_integer])
		pool.remove(random_integer)

func key_translator(string):
	if string == "none":
		return 0
	elif string == "tentacles":
		return 1
	elif string == "double_pipe":
		return 2
	elif string == "triple_pipe":
		return 3
	elif string == "wall":
		return 4
	elif string == "laser_eye":
		return 5
	elif string == "shield_up":
		return 6
	elif string == "ammo_up":
		return 7
	else:
		return "ERROR"