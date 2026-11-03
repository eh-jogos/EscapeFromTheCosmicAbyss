class_name Level
extends RefCounted

## Write your doc string for this file here

#region Member Variables and Dependencies ---------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var title: String = ""

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
var bosses: Array[BossData] = []

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
	_reset_base_properties()
	_level_data = p_level_data
	title = _level_data.title
	
	if _level_data.boss_type != LevelData.BossTypes.NONE:
		var boss_data: BossData = BossData.new(_level_data, beats.size())
		bosses.append(boss_data)
	_build_level_procedurally()
	
	_set_count_properties()


func initialize_multiple_levels(p_data_array: Array[LevelData], should_loop: bool = false) -> void:
	_reset_base_properties()
	
	for index: int in p_data_array.size():
		_level_data = p_data_array[index]
		
		if _level_data.boss_type != LevelData.BossTypes.NONE:
			var boss_data: BossData = BossData.new(_level_data, beats.size())
			bosses.append(boss_data)
		_build_level_procedurally()
		
		if index < p_data_array.size()-1:
			half_beats.append(LevelData.ObstacleTypes.NONE)
			beats.append(LevelData.ObstacleTypes.SHIELD_UP)
			half_beats.append(LevelData.ObstacleTypes.NONE)
		elif index == p_data_array.size()-1 and should_loop:
			half_beats.append(LevelData.ObstacleTypes.NONE)
			beats.append(LevelData.ObstacleTypes.SHIELD_UP)
	
	_set_count_properties()

#endregion Public Methods -------------------------------------------------------------------------


#region Private Methods ---------------------------------------------------------------------------

func _reset_base_properties() -> void:
	beats.clear()
	half_beats.clear()
	bosses.clear()
	count_beats = 0
	count_half_beats = 0
	count_total = 0


func _set_count_properties() -> void:
	count_beats = beats.size()
	count_half_beats = half_beats.size()
	count_total = count_beats + count_half_beats


func _build_level_procedurally() -> void:
	var total_count: int = _sum_all_beats_and_halfs()
	
	var complete_level: Array[int] = []
	complete_level.resize(total_count)
	complete_level.fill(-1)
	
	_add_fixed_sections_to(complete_level)
	
	var beat_obstacles_pool: Dictionary = _level_data.beats.duplicate()
	var half_obstacles_pool: Dictionary = _level_data.half_beats.duplicate()
	_add_laser_eyes_to(complete_level, beat_obstacles_pool, half_obstacles_pool)
	_add_tentacle_barriers_to(complete_level, beat_obstacles_pool, half_obstacles_pool)
	_add_standard_obstacles_to(complete_level, beat_obstacles_pool, half_obstacles_pool)
	_fill_empty_beats_on_free_slots(complete_level)
	
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


func _build_available_slots_array(level_array: Array, initial_slot: int) -> Array[int]:
	var available_slots: Array[int] = \
			Array(range(initial_slot, level_array.size(), 2),TYPE_INT, "", null)
	var slots_to_remove: Array[int] = []
	for index in available_slots.size():
		var level_index: int = available_slots[index]
		
		if level_array[level_index] > -1:
			slots_to_remove.append(index)
	
	for index in range(slots_to_remove.size()-1, -1, -1):
		var slot_index := slots_to_remove[index]
		available_slots.remove_at(slot_index)
	
	return available_slots


func _draw_random_obstacle(obstacle_pool: Dictionary) -> String:
	var value := ""
	var obstacle_count: int = obstacle_pool.values().reduce(Utilities.sum_array)
	if obstacle_count == 1:
			for key in obstacle_pool:
				if obstacle_pool[key] > 0:
					value = key
	else:
		var weights_sum := obstacle_count as float
		var random_value := randf_range(0, weights_sum)
		for key in obstacle_pool:
			var current_weight := obstacle_pool[key] as float
			if random_value < current_weight:
				value = key
				break
			else:
				random_value -= current_weight
	
	return value


func _fill_empty_beats_on_free_slots(level_array: Array[int]) -> void:
	for index in level_array.size():
		if level_array[index] == -1:
			push_warning(
					"There shouldn't be any remaining unused slots, replacing with empty obstacle"
			)
			level_array[index] = 0


func _replace_remaining_obstacle_by(
		obstacle_pool: Dictionary, to_remove: String, to_add: String
) -> void:
	if obstacle_pool[to_remove] > 0:
		obstacle_pool[to_add] += obstacle_pool[to_remove]
		obstacle_pool[to_remove] = 0

#region Fixed Sections Handling -------------------------------------------------------------------

func _add_fixed_sections_to(level_array: Array) -> void:
	var intro_beats := _level_data.intro_beats.duplicate()
	var intro_halfs :=  _level_data.intro_halfs.duplicate()
	
	_add_fixed_section(level_array, intro_beats, 0)
	_add_fixed_section(level_array, intro_halfs, 1)
	
	if _level_data.has_boss_scream:
		var boss_scream_beats: Array[Array] = _level_data.scream_sequence_beats.duplicate(true)
		var boss_scream_halfs: Array[Array] = _level_data.scream_sequence_halfs.duplicate(true)
		
		for index in range(_level_data.scream_countdowns.size()):
			var countdown_to_start := _level_data.scream_countdowns[index]
			var starting_beat := countdown_to_start * 2
			var starting_half_beat := starting_beat + 1
			
			var scream_beats := boss_scream_beats[index]
			var scream_halfs := boss_scream_halfs[index]
			
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

#endregion Fixed Sections Handling ----------------------------------------------------------------

#region Laser Eye Handling ------------------------------------------------------------------------

func _add_laser_eyes_to(
		level_array: Array[int], beats_pool: Dictionary, half_beats_pool: Dictionary
) -> void:
	if beats_pool.laser_eye == 0 and half_beats_pool.laser_eye == 0:
		return
	
	if beats_pool.laser_eye > 0:
		_draw_laser_eye(level_array, beats_pool, 0)
		if beats_pool.laser_eye > 0:
			_replace_remaining_obstacle_by(beats_pool, "laser_eye", "double_tentacle")
	
	if beats_pool.laser_eye > 0:
		_draw_laser_eye(level_array, half_beats_pool, 1)
		if half_beats_pool.laser_eye > 0:
			_replace_remaining_obstacle_by(beats_pool, "laser_eye", "double_tentacle")


func _draw_laser_eye(level_array: Array, obstacle_pool: Dictionary, initial_slot: int) -> void:
	var available_slots: Array[int] = []
	
	var level_name = _level_data.resource_name
	if level_name == "Level5":
		available_slots = _get_available_slots_after_first_boss_appears(level_array)
	else:
		available_slots = _build_available_slots_array(level_array, initial_slot)
	
	while obstacle_pool.laser_eye > 0 and not available_slots.is_empty():
		var random_index = randi()%available_slots.size()
		var level_position = available_slots[random_index]
		
		var is_another_laser_eye_close_by = false
		var initial_pos = max(level_position - 5, 0)
		var end_pos = min(level_position + 5, level_array.size())
		
		if end_pos >= level_array.size():
			var msg := "Remaining beats in level is too short for full Laser Eye pattern"\
					+"| aborting laser eye"
			push_error(msg)
			continue
		
		for index in range(initial_pos, end_pos):
			if level_array[index] == LevelData.ObstacleTypes.LASER_EYE:
				is_another_laser_eye_close_by = true
				available_slots.remove_at(random_index)
				continue
		
		if not is_another_laser_eye_close_by:
			level_array[level_position] = LevelData.ObstacleTypes.LASER_EYE
			obstacle_pool.laser_eye -= 1
			available_slots.remove_at(random_index)
			for position in range(initial_pos, end_pos):
				if available_slots.has(position):
					available_slots.erase(position)


func _get_available_slots_after_first_boss_appears(level_array: Array[int]):
	# index 2 is after Boss screams, index 1 is after it gets angry but hasn't screamed yet.
	# +1 because we want laser eyes to be available at least 1 beat after the scream
	var offset: int = _level_data.boss_animations_countdowns[2]+1
	
	if beats.size() > 0:
		#This should only be true when playing in Arcade or Speedrun modes, which glue together
		#multiple levels.
		offset -= beats.size()
	
	var available_slots: Array[int] = _build_available_slots_array(level_array, offset)
	return available_slots

#endregion Laser Eye Handling ---------------------------------------------------------------------

#region Tentacle Wall Handling --------------------------------------------------------------------

func _add_tentacle_barriers_to(
		level_array: Array[int], beats_pool: Dictionary, half_beats_pool: Dictionary
) -> void:
	if beats_pool.wall_tentacle == 0 and half_beats_pool.wall_tentacle == 0:
		return
	
	if beats_pool.wall_tentacle > 0:
		_draw_wall_tentacles(level_array, beats_pool, 0)
		if beats_pool.wall_tentacle > 0:
			_replace_remaining_obstacle_by(beats_pool, "wall_tentacle", "tentacles")
	
	if half_beats_pool.wall_tentacle > 0:
		_draw_wall_tentacles(level_array, half_beats_pool, 1)
		if half_beats_pool.wall_tentacle > 0:	
			_replace_remaining_obstacle_by(beats_pool, "wall_tentacle", "tentacles")


func _draw_wall_tentacles(level_array: Array, obstacle_pool: Dictionary, initial_slot: int) -> void:
	const BEATS_TO_GET_AMMO := 5.0
	var available_slots: Array[int] = _build_available_slots_array(level_array, initial_slot)
	
	while obstacle_pool.wall_tentacle > 0 and not available_slots.is_empty():
		var random_integer := randi()%available_slots.size()
		var level_position := available_slots[random_integer]
		var end_position: int = mini(level_position+1, level_array.size())
		
		var wall_count = 0
		for position: int in range(end_position):
			if position == level_position:
				wall_count +=1
			elif level_array[position] == LevelData.ObstacleTypes.WALL_TENTACLE:
				wall_count +=1
		
		if wall_count <= end_position / BEATS_TO_GET_AMMO:
			level_array[level_position] = LevelData.ObstacleTypes.WALL_TENTACLE
			obstacle_pool.wall_tentacle -= 1
			available_slots.remove_at(random_integer)
		elif wall_count >= level_array.size() / BEATS_TO_GET_AMMO:
			break

#endregion Tentacle Wall Handling -----------------------------------------------------------------

#region Standard Obstacles Handling ---------------------------------------------------------------

func _add_standard_obstacles_to(
		level_array: Array[int], beats_pool: Dictionary, half_beats_pool: Dictionary
) -> void:
	if beats_pool.values().reduce(Utilities.sum_array) > 0:
		_draw_standard_obstacles(level_array, beats_pool, 0)
		
	if half_beats_pool.values().reduce(Utilities.sum_array) > 0:
		_draw_standard_obstacles(level_array, half_beats_pool, 1)


func _draw_standard_obstacles(
		level_array: Array, obstacle_pool: Dictionary, initial_slot: int
) -> void:
	var available_slots: Array = _build_available_slots_array(level_array, initial_slot)
	
	var obstacle_count: int = obstacle_pool.values().reduce(Utilities.sum_array)
	while obstacle_count > 0 and available_slots.size() > 0:
		var random_index: int = randi()%available_slots.size()
		var level_position: int = available_slots[random_index]
		
		var random_obstacle: String = _draw_random_obstacle(obstacle_pool)
		level_array[level_position] = LevelData.ObstacleTypes[random_obstacle.to_upper()]
		available_slots.remove_at(random_index)
		obstacle_pool[random_obstacle] -= 1
		obstacle_count = obstacle_pool.values().reduce(Utilities.sum_array)

#endregion Standard Obstacles Handling ------------------------------------------------------------

#endregion Private Methods ------------------------------------------------------------------------
