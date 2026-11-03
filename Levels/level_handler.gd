class_name LevelHandler
extends Node

## Small node responsible for holding all level data, and creating actual Level object based
## on game mode and stage and returning it to the game.

#region Member Variables and Dependencies ---------------------------------------------------------

@export var _levels: Array[LevelData] = []
var _level: Level = null

#endregion Member Variables and Dependencies ------------------------------------------------------


#region Built in Engine Methods -------------------------------------------------------------------

func _ready() -> void:
	for index: int in _levels.size():
		var level_data := _levels[index]
		assert(level_data != null, "No Level data at _levels[%s]"%[index])
		level_data.validate_level()

#endregion Built in Engine Methods ----------------------------------------------------------------


#region Public Methods ----------------------------------------------------------------------------

## Given a [param level index], chooses the correct level data, builds the Level object from
## it, and returns it. When loading "arcade" or "speedrun" game modes, [param level_index] 
## doesn't matter, use [param should_load_all] and [param should_loop] accordingly.
func load_level(level_index: int, should_load_all: bool, should_loop: bool) -> Level:
	_level = Level.new()
	if should_load_all:
		var level_selection := _levels.duplicate()
		# Remove tutorial level
		level_selection.remove_at(0)
		_level.initialize_multiple_levels(level_selection, should_loop)
	else:
		assert(level_index >= 0 and level_index < _levels.size(), "Invalid level index")
		var level_data := _levels[level_index]
		_level.initialize_single_level(level_data)
	
	return _level


## Returns total levels count.
func get_levels_count():
	return _levels.size()

#endregion Public Methods -------------------------------------------------------------------------
