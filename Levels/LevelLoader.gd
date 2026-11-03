extends Node

@export var levels: Array[LevelData] = []

var level: Level = null

func _ready() -> void:
	for index: int in levels.size():
		var level_data := levels[index]
		assert(level_data != null, "No Level data at levels[%s]"%[index])
		level_data.validate_level()


func load_level(level_index: int, should_load_all: bool, should_loop: bool) -> Level:
	if should_load_all:
		pass
	else:
		assert(level_index >= 0 and level_index < levels.size(), "Invalid level index")
		var level_data := levels[level_index]
		level = Level.new()
		level.initialize_single_level(level_data)
	
	return level


func get_max_levels():
	return levels.size()
