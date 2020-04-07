extends Node

var level = {}
var level_info

func load_level(num, load_all, loop):
	if load_all:
		level["beats"] = []
		level["half_beats"] = []
		for x in range(num, self.get_max_levels()):
			level_info = get_child(x)
			
			build_level_procedurally()
			
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
		level["beats"] = []
		level["half_beats"] = []
		level["bosses_nodes"] = {}
		
		if level_info.boss.boss_node != null:
			level["bosses_nodes"][level_info.boss.boss_node] = {
				"is_a_boss_level" : level_info.boss.boss_level,
				"animations" : level_info.boss.animations,
				"animation_countdowns" : level_info.boss.animations_countdowns,
				"laser_countdowns" : level_info.boss.laser_countdowns,
			}
		
		build_level_procedurally()
		
		level["total_count"] = level["beats"].size() + level["half_beats"].size()
	return level


func build_level_procedurally():
	var total_count = sum_all_beats_and_halfs()
	
	var complete_level = []
	for x in range(total_count):
		complete_level.append(null)
	
	complete_level = add_fixed_sections_step(complete_level)
	
	var beat_obstacles_pool = build_obstacle_pool(level_info["beats"])
	var half_obstacles_pool = build_obstacle_pool(level_info["half_beats"])
	complete_level = laser_eye_draw_step(complete_level, beat_obstacles_pool, half_obstacles_pool)
	complete_level = tentacle_barrier_draw_step(complete_level, beat_obstacles_pool, half_obstacles_pool)
	complete_level = standard_draw_step(complete_level, beat_obstacles_pool, half_obstacles_pool)
	#print("LevelLoader.gd | build_level_procedurally | beats_pool: %s | half_beats_pool: %s | complete_level: %s"%[beat_obstacles_pool, half_obstacles_pool, complete_level])
	
	for x in range(complete_level.size()):
		if x % 2 == 0:
			level["beats"].append(complete_level[x])
		else:
			level["half_beats"].append(complete_level[x])


func sum_all_beats_and_halfs():
	var total_count = level_info.intro_beats.size() + level_info.intro_halfs.size()
	
	if level_info.boss["scream"]:
		for array in level_info.boss["sequence_beats"]:
			total_count += array.size()
		for array in level_info.boss["sequence_halfs"]:
			total_count += array.size()
	
	for key in level_info.beats:
		if level_info.beats[key]>0:
			total_count += level_info.beats[key]
	
	for key in level_info.half_beats:
		if level_info.half_beats[key]>0:
			total_count += level_info.half_beats[key]
	
	#add 1 for the end beat
	total_count += 1
	
	return total_count


func add_fixed_sections_step(level_array):
	var duplicate_level = [] + level_array
	var intro_beats =  [] + level_info.intro_beats
	var intro_halfs =  [] + level_info.intro_halfs
	
	add_fixed_section(duplicate_level, intro_beats, 0)
	add_fixed_section(duplicate_level, intro_halfs, 1)
	
	if level_info.boss.scream:
		var boss_scream_beats =  [] + level_info.boss["sequence_beats"]
		var boss_scream_halfs =  [] + level_info.boss["sequence_halfs"]
		
		for scream_iteration in range(level_info.boss.countdown.size()):
			var starting_beat = level_info.boss.countdown[scream_iteration] * 2
			var starting_half_beat = starting_beat + 1
			
			add_fixed_section(duplicate_level, boss_scream_beats[scream_iteration], starting_beat)
			add_fixed_section(duplicate_level, boss_scream_halfs[scream_iteration], starting_half_beat)
	
	duplicate_level[-1] = level_info.end_beat
	
	return duplicate_level


func add_fixed_section(target_array, fixed_section, starting_pos):
	for x in range(starting_pos, target_array.size(), 2):
		if fixed_section.size() > 0:
			target_array[x] = fixed_section[0]
			fixed_section.pop_front()
		else:
			break


func laser_eye_draw_step(level_array, beats_pool, half_beats_pool):
	if level_info.beats.laser_eye == 0 and level_info.half_beats.laser_eye == 0:
		return level_array
	
	var duplicate_level = [] + level_array
	
	if level_info.beats.laser_eye > 0:
		duplicate_level = draw_laser_eye(duplicate_level, beats_pool, 0)
		if beats_pool.has(key_translator("laser_eye")):
			replace_remaining_laser_eyes(beats_pool)
	
	if level_info.beats.laser_eye > 0:
		duplicate_level = draw_laser_eye(duplicate_level, half_beats_pool, 1)
		if half_beats_pool.has(key_translator("laser_eye")):
			replace_remaining_laser_eyes(half_beats_pool)
	
	return duplicate_level


func draw_laser_eye(level_array, obstacle_pool, initial_slot):
	var available_slots
	
	print("LevelLoader | Level name: %s"%[level_info.get_name()])
	var level_name = level_info.get_name()
	if level_info.get_name() == "Level5":
		available_slots = get_available_slots_on_laser_eye_introductory_level(level_array, initial_slot)
	else:
		available_slots = build_available_slots_array(level_array, initial_slot)
	
	for _x in range(available_slots.size()):
		if obstacle_pool.has(key_translator("laser_eye")):
			var random_integer = randi()%available_slots.size()
			var level_position = available_slots[random_integer]
			
			var is_another_laser_eye_close_by = false
			var initial_pos = level_position-5
			var end_pos = level_position + 5
			
			if initial_pos < 0:
				initial_pos = 0
			if end_pos >= level_array.size():
				continue
			
			for index in range(initial_pos, end_pos):
				if level_array[index] == key_translator("laser_eye"):
					is_another_laser_eye_close_by = true
					available_slots.remove(random_integer)
					continue
			
			if not is_another_laser_eye_close_by:
				level_array[level_position] = key_translator("laser_eye")
				obstacle_pool.erase(key_translator("laser_eye"))
				available_slots.remove(random_integer)
		else:
			break
	
	return level_array


func get_available_slots_on_laser_eye_introductory_level(level_array, initial_slot):
	var available_slots
	available_slots = build_available_slots_array(level_array, level_info.boss.animations_countdowns[1]+1)
	
	return available_slots


func replace_remaining_laser_eyes(obstacle_pool):
	var drop_count = 0
	var last_index = 0
	print("LevelLoader.gd | replace_remaining_laser_eyes | obstacle_pool: %s"%[obstacle_pool])
	while obstacle_pool.has(key_translator("laser_eye")):
		drop_count += 1
		last_index = obstacle_pool.find(key_translator("laser_eye"), last_index)
		
		# if it doesn't find a laser eye, it shouldn't even be in this while, but as a safeguard I'm checking for it
		if last_index == -1:
			break
		
		#replace laser eye that was not drawn by a double_pipe
		obstacle_pool[last_index] = key_translator("double_pipe")
	
	print("LevelLoader.gd | replace_remaining_laser_eyes | obstacle_pool: %s | drop_count: %s"%[obstacle_pool, drop_count])


func tentacle_barrier_draw_step(level_array, beats_pool, half_beats_pool):
	if level_info.beats.wall == 0 and level_info.half_beats.wall == 0:
		return level_array
	
	var duplicate_level = [] + level_array
	
	if level_info.beats.wall > 0:
		duplicate_level = draw_tentacle_barrier(duplicate_level, beats_pool, 0)
		if beats_pool.has(key_translator("wall")):
			replace_remaining_tentacle_barriers(beats_pool)
	
	if level_info.beats.wall > 0:
		duplicate_level = draw_tentacle_barrier(duplicate_level, half_beats_pool, 1)
		if half_beats_pool.has(key_translator("wall")):
			replace_remaining_tentacle_barriers(half_beats_pool)
	
	return duplicate_level


func draw_tentacle_barrier(level_array, obstacle_pool, initial_slot):
	var available_slots = build_available_slots_array(level_array, initial_slot)
	
	for _x in range(available_slots.size()):
		if obstacle_pool.has(key_translator("wall")):
			var random_integer = randi()%available_slots.size()
			var level_position = available_slots[random_integer]
			var end_position = min(level_position+10, level_array.size())
			
			var wall_count = 0
			for position in range(end_position):
				if position == level_position:
					wall_count +=1
				elif level_array[position] == key_translator("wall"):
					wall_count +=1
			
			if level_position % 10 >= wall_count:
				level_array[level_position] = key_translator("wall")
				obstacle_pool.erase(key_translator("wall"))
				available_slots.remove(random_integer)
		else:
			break
	
	return level_array


func replace_remaining_tentacle_barriers(obstacle_pool):
	var drop_count = 0
	var last_index = 0
	print("LevelLoader.gd | replace_remaining_tentacle_barriers | obstacle_pool: %s"%[obstacle_pool])
	while obstacle_pool.has(key_translator("wall")):
		drop_count += 1
		last_index = obstacle_pool.find(key_translator("wall"), last_index)
		
		# if it doesn't find a laser eye, it shouldn't even be in this while, but as a safeguard I'm checking for it
		if last_index == -1:
			break
		
		#replace laser eye that was not drawn by a double_pipe
		obstacle_pool[last_index] = key_translator("tentacles")
	
	print("LevelLoader.gd | replace_remaining_tentacle_barriers | obstacle_pool: %s | drop_count: %s"%[obstacle_pool, drop_count])


func standard_draw_step(level_array, beats_pool, half_beats_pool):
	var duplicate_level = [] + level_array
	
	if beats_pool.size() > 0:
		duplicate_level = draw_obstacles(duplicate_level, beats_pool, 0)
		
	if half_beats_pool.size() > 0:
		duplicate_level = draw_obstacles(duplicate_level, half_beats_pool, 1)
		
	return duplicate_level


func draw_obstacles(level_array, obstacle_pool, initial_slot):
	var available_slots = build_available_slots_array(level_array, initial_slot)
	
	for _x in range(available_slots.size()):
		if obstacle_pool.size() > 0:
			var random_integer = randi()%available_slots.size()
			var level_position = available_slots[random_integer]
			
			var random_obstacle = randi()%obstacle_pool.size()
			level_array[level_position] = obstacle_pool[random_obstacle]
			obstacle_pool.remove(random_obstacle)
			available_slots.remove(random_integer)
		else:
			break
	
	return level_array


func build_available_slots_array(level_array, initial_slot):
	var available_slots = range(initial_slot, level_array.size(), 2)
	var slots_to_remove = []
	for slot in available_slots:
		if level_array[slot] != null:
			slots_to_remove.append(slot)
	
	for slot in slots_to_remove:
		available_slots.erase(slot)
	
	return available_slots


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