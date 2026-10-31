class_name Level
extends RefCounted

## Write your doc string for this file here

#region Member Variables and Dependencies ---------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var title: String = "":
	get():
		var value := ""
		if _level_data:
			value = _level_data.title
		return value

var intro_cutscene: String = "":
	get():
		var value := ""
		if _level_data:
			value = _level_data.intro_cutscene
		return value

var end_cutscene: String = "":
	get():
		var value := ""
		if _level_data:
			value = _level_data.end_cutscene
		return value

var is_tutorial: bool = false:
	get():
		var value := false
		if _level_data:
			value = _level_data.is_tutorial
		return value

var beats: Array[int] = []
var half_beats: Array[int] = []
var boss_nodes: Array[int] = []

var count_beats: int = 0
var count_half_beats: int = 0
var count_total: int = 0

#--- private variables - order: export > normal var > onready -------------------------------------

var _level_data: LevelData = null

#endregion Member Variables and Dependencies ------------------------------------------------------


#region Built in Engine Methods -------------------------------------------------------------------

#endregion Built in Engine Methods ----------------------------------------------------------------


#region Public Methods ----------------------------------------------------------------------------

func initialize_single_level(p_level_data: LevelData) -> void:
	_level_data = p_level_data
	beats.clear()
	half_beats.clear()
	boss_nodes.clear()
	
	_build_level_procedurally()
	
	count_beats = beats.size()
	count_half_beats = half_beats.size()
	count_total = count_beats + count_half_beats

#endregion Public Methods -------------------------------------------------------------------------


#region Private Methods ---------------------------------------------------------------------------

func _build_level_procedurally() -> void:
	var total_count = _sum_all_beats_and_halfs()
	
	var complete_level = []
	complete_level.resize(total_count)
	
	_add_fixed_sections_to(complete_level)
	
	var beat_obstacles_pool = _level_data.beats.duplicate()
	var half_obstacles_pool = _level_data.half_beats.duplicate()
	_add_laser_eyes_to(complete_level, beat_obstacles_pool, half_obstacles_pool)
	_add_tentacle_barriers_to(complete_level, beat_obstacles_pool, half_obstacles_pool)
	_add_standard_obstacles_to(complete_level, beat_obstacles_pool, half_obstacles_pool)
	
	for x in range(complete_level.size()):
		if x % 2 == 0:
			beats.append(complete_level[x])
		else:
			half_beats.append(complete_level[x])


func _sum_all_beats_and_halfs() -> int:
	var total_count: int = _level_data.intro_beats.size() + _level_data.intro_halfs.size()
	
	if _level_data.has_boss_scream:
		for array: Array in _level_data.scream_sequence_beats:
			total_count += array.size()
		for array in _level_data.scream_sequence_halfs:
			total_count += array.size()
	
	for obstacle_type: String in _level_data.beats:
		total_count += _level_data.beats[obstacle_type]
	
	for obstacle_type: String in _level_data.half_beats:
		total_count += _level_data.half_beats[obstacle_type]
	
	#add 1 for the end beat
	total_count += 1
	
	return total_count


func _add_fixed_sections_to(level_array: Array) -> void:
	var intro_beats := _level_data.intro_beats.duplicate()
	var intro_halfs :=  _level_data.intro_halfs.duplicate()
	
	_add_fixed_section(level_array, intro_beats, 0)
	_add_fixed_section(level_array, intro_halfs, 1)
	
	if _level_data.has_boss_scream:
		var boss_scream_beats := _level_data.scream_sequence_beats.duplicate(true)
		var boss_scream_halfs := _level_data.scream_sequence_halfs.duplicate(true)
		
		for index in range(_level_data.scream_countdowns.size()):
			var countdown_to_start := _level_data.scream_countdowns[index]
			var starting_beat := countdown_to_start * 2
			var starting_half_beat := starting_beat + 1
			
			var scream_beats := _level_data.scream_sequence_beats[index]
			var scream_halfs := _level_data.scream_sequence_halfs[index]
			
			_add_fixed_section(level_array, scream_beats, starting_beat)
			_add_fixed_section(level_array, scream_halfs, starting_half_beat)
	
	level_array[-1] = _level_data.end_beat


func _add_fixed_section(target_array: Array, fixed_section: Array, starting_pos: int):
	for index in range(starting_pos, target_array.size(), 2):
		if fixed_section.size() > 0:
			var value: int = fixed_section.pop_front()
			target_array[index] = value
		else:
			break


func _draw_random_obstacle(obstacle_pool: Dictionary) -> String:
	var value := ""
	var obstacle_count: int = obstacle_pool.values().reduce(Utilities.sum_array)
	if obstacle_count == 1:
			for key in obstacle_pool:
				if obstacle_pool[key] > 0:
					value = obstacle_pool[key]
	else:
		var weights_sum := obstacle_count as float
		var random_value := randf_range(0, weights_sum)
		for key in obstacle_pool:
			var current_weight := obstacle_pool[key] as float
			if random_value < current_weight:
				value = key
				obstacle_pool[key] -= 1
				break
			else:
				random_value -= current_weight
	
	return value

#endregion Private Methods ------------------------------------------------------------------------
