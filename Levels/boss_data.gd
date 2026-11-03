class_name BossData
extends RefCounted

## Small RefCounted class to handle Boss data during runtime.

#region Member Variables and Dependencies ---------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

var boss_type: int = -1
var animation_names: Array[String] = []
var animation_countdowns: Array[int] = []
var laser_countdown: Array[int] = []
var danger_durations: Array[int] = []

#--- private variables - order: export > normal var > onready -------------------------------------

#endregion Member Variables and Dependencies ------------------------------------------------------


#region Built in Engine Methods -------------------------------------------------------------------

func _init(p_level_data: LevelData, offset: int = 0) -> void:
	boss_type = p_level_data.boss_type
	animation_names = p_level_data.boss_animations
	animation_countdowns = _shift_countdowns_by(p_level_data.boss_animations_countdowns, offset)
	laser_countdown = _shift_countdowns_by(p_level_data.laser_countdowns, offset)
	danger_durations = p_level_data.danger_durations
	pass

#endregion Built in Engine Methods ----------------------------------------------------------------


#region Public Methods ----------------------------------------------------------------------------

#endregion Public Methods -------------------------------------------------------------------------


#region Private Methods ---------------------------------------------------------------------------

func _shift_countdowns_by(countdown_array: Array, offset: int) -> Array:
	for index in countdown_array.size():
		countdown_array[index] += offset
	return countdown_array

#endregion Private Methods ------------------------------------------------------------------------
