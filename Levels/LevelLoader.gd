extends Node

var level: Level = null
var level_node: Node

var _d_level: Level = null

@export var _test_level: LevelData = null

func _ready() -> void:
	pass


func load_level(level_index: int, should_load_all: bool, should_loop: bool) -> Level:
	_test_level.validate_level()
	_d_level = Level.new()
	_d_level.initialize_single_level(_test_level)
	level = _d_level
	if should_load_all:
		pass
	else:
		pass
	
	return level


func get_max_levels():
	return get_child_count()
