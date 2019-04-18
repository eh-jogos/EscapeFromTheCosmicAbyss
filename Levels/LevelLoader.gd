extends Node

var level = {}
var level_info

func load_level(num, load_all, loop):
	if load_all:
		for x in range(num, self.get_max_levels()):
			level_info = get_child(x)
			build_boss()
			build_beats()
			build_half_beats()
			if x != self.get_max_levels()-1:
				level["half_beats"].append(0)
				level["beats"].append(6)
				level["half_beats"].append(0)
			elif x == self.get_max_levels()-1 and loop:
				level["half_beats"].append(0)
				level["beats"].append(6)
		level["beats_count"] = level["beats"].size()
		level["half_count"] = level["half_beats"].size()
		level["total_count"] = level["beats"].size() + level["half_beats"].size()
	else:
		level_info = get_child(num)
		level["title"] = level_info.title
		level["tutorial"] = level_info.tutorial
		level["intro_cutscene"] = level_info.intro_cutscene
		level["end_cutscene"] = level_info.end_cutscene
		build_boss()
		build_beats()
		build_half_beats()
		level["total_count"] = level["beats"].size() + level["half_beats"].size()
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
	if not level.has("beats"):
		level["beats"] = []
	
	add_intro(level["beats"], level_info.intro_beats)
	obstacle_pool = build_obstacle_pool(level_info["beats"])
	build_random_level(level["beats"], obstacle_pool)
	check_barrier_positions()
	level["beats"].append(level_info.end_beat)

func build_half_beats():
	var obstacle_pool = []
	if not level.has("half_beats"): 
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

func check_barrier_positions():
	pass

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

func get_max_levels():
	return self.get_child_count()