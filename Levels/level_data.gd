@tool
class_name LevelData
extends Resource

## Write your doc string for this file here

#region Member Variables and Dependencies ---------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

enum ObstacleTypes {
	NONE,
	TENTACLE,
	DOUBLE_TENTACLE,
	TRIPLE_TENTACLE,
	WALL_TENTACLE,
	LASER_EYE,
	SHIELD_UP,
	AMMO_UP,
}

enum BossTypes {
	NONE,
	BackRowBoss,
	MidBackRowBoss,
	MidFrontRowBoss,
	Boss
}

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

@export var title: String = ""
@export_file var intro_cutscene: String = ""
@export_file var end_cutscene: String = ""

@export var is_tutorial: bool = false
@export var intro_beats: Array[ObstacleTypes] = []:
	set(value):
		intro_beats = value
		intro_halfs.resize(intro_beats.size())
		notify_property_list_changed()
@export var intro_halfs: Array[ObstacleTypes] = []
@export var end_beat: ObstacleTypes = ObstacleTypes.WALL_TENTACLE

@export_group("On Beat Obstacles", "on_beat_")
@export_storage var beats: Dictionary = {
	"none": 0,
	"tentacles": 0,
	"double_pipe": 0,
	"triple_pipe": 0,
	"wall": 0,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}
@export_range(0, 1, 1, "or_greater") var on_beat_none: int = 0
@export_range(0, 1, 1, "or_greater") var on_beat_tentacles: int = 0
@export_range(0, 1, 1, "or_greater") var on_beat_double_tentacles: int = 0
@export_range(0, 1, 1, "or_greater") var on_beat_triple_tentacles: int = 0
@export_range(0, 1, 1, "or_greater") var on_beat_wall_tentacles: int = 0
@export_range(0, 1, 1, "or_greater") var on_beat_laser_eye: int = 0
@export_range(0, 1, 1, "or_greater") var on_beat_shield_up: int = 0
@export_range(0, 1, 1, "or_greater") var on_beat_ammo_up: int = 0

@export_group("On Half Beat Obstacles", "on_half_")
@export_storage var half_beats: Dictionary = {
	"none": 0,
	"tentacles": 0,
	"double_pipe": 0,
	"triple_pipe": 0,
	"wall": 0,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}
@export_range(0, 1, 1, "or_greater") var on_half_none: int = 0
@export_range(0, 1, 1, "or_greater") var on_half_tentacles: int = 0
@export_range(0, 1, 1, "or_greater") var on_half_double_tentacles: int = 0
@export_range(0, 1, 1, "or_greater") var on_half_triple_tentacles: int = 0
@export_range(0, 1, 1, "or_greater") var on_half_wall_tentacles: int = 0
@export_range(0, 1, 1, "or_greater") var on_half_laser_eye: int = 0
@export_range(0, 1, 1, "or_greater") var on_half_shield_up: int = 0
@export_range(0, 1, 1, "or_greater") var on_half_ammo_up: int = 0

var is_boss_level: bool = false:
	set(value):
		is_boss_level = value
		notify_property_list_changed()
var boss_type: BossTypes = BossTypes.NONE:
	set(value):
		boss_type = value
		notify_property_list_changed()
var has_boss_laser: bool = false:
	set(value):
		has_boss_laser = value
		notify_property_list_changed()
var laser_countdowns: Array[int] = []
var boss_animations: Array[String] = []:
	set(value):
		var has_changed_size := value.size() != boss_animations.size()
		boss_animations = value
		if has_changed_size:
			boss_animations_countdowns.resize(boss_animations.size())
			danger_durations.resize(boss_animations.size())
			notify_property_list_changed()
var boss_animations_countdowns: Array[int] = []
var danger_durations: Array[int] = []
var has_boss_scream: bool = false:
	set(value):
		has_boss_scream = value
		notify_property_list_changed()
var scream_countdowns: Array[int] = []
var scream_sequence_beats: Array[Array] = []
var scream_sequence_halfs: Array[Array] = []


#--- private variables - order: export > normal var > onready -------------------------------------

#endregion Member Variables and Dependencies ------------------------------------------------------


#region Built in Engine Methods -------------------------------------------------------------------

func _get_property_list() -> Array[Dictionary]:
	var value: Array[Dictionary] = []
	_add_boss_settings_properties_to(value)
	
	return value

#endregion Built in Engine Methods ----------------------------------------------------------------


#region Public Methods ----------------------------------------------------------------------------

#endregion Public Methods -------------------------------------------------------------------------


#region Private Methods ---------------------------------------------------------------------------

func _add_boss_settings_properties_to(property_list: Array[Dictionary]) -> void:
	property_list.append(_get_category_dict("Boss Settings"))
	property_list.append(_get_property_dict("is_boss_level", TYPE_BOOL))
	property_list.append(
		_get_property_dict(
			"boss_type", TYPE_INT, PROPERTY_HINT_ENUM, ",".join(BossTypes.keys())
		)
	)
	
	if boss_type != BossTypes.NONE:
		property_list.append(_get_property_dict("has_boss_laser", TYPE_BOOL))
		if has_boss_laser:
			property_list.append(
				_get_property_dict(
					"laser_countdowns", 
					TYPE_ARRAY, 
					PROPERTY_HINT_ARRAY_TYPE,
					"int"
				)
			)
		
		property_list.append(
			_get_property_dict(
				"boss_animations", 
				TYPE_ARRAY, 
				PROPERTY_HINT_ARRAY_TYPE,
				"String"
			)
		)
		if boss_animations.size() > 0:
			property_list.append(
				_get_property_dict(
					"boss_animations_countdowns",
					TYPE_ARRAY,
					PROPERTY_HINT_TYPE_STRING,
					"%d/%d:0,1,1,or_greater"%[TYPE_INT, PROPERTY_HINT_RANGE]
				)
			)
			property_list.append(
				_get_property_dict(
					"danger_durations",
					TYPE_ARRAY,
					PROPERTY_HINT_TYPE_STRING,
					"%d/%d:0,1,1,or_greater"%[TYPE_INT, PROPERTY_HINT_RANGE]
				)
			)
		
		property_list.append(_get_property_dict("has_boss_scream", TYPE_BOOL))
		if has_boss_scream:
			property_list.append(
				_get_property_dict(
					"scream_sequence_beats",
					TYPE_ARRAY, 
					PROPERTY_HINT_TYPE_STRING, 
					"%d:%d/%d:%s"%[
							TYPE_ARRAY, 
							TYPE_INT, 
							PROPERTY_HINT_ENUM, 
							",".join(ObstacleTypes.keys())
					]
				)
			)
			property_list.append(
				_get_property_dict(
					"scream_sequence_halfs",
					TYPE_ARRAY, 
					PROPERTY_HINT_TYPE_STRING, 
					"%d:%d/%d:%s"%[
							TYPE_ARRAY, 
							TYPE_INT, 
							PROPERTY_HINT_ENUM, 
							",".join(ObstacleTypes.keys())
					]
				)
			)


static func _get_property_dict(
		p_name: String, 
		p_type: Variant.Type,
		p_hint: int = PROPERTY_HINT_NONE,
		p_hint_string: String  = "",
		p_class_name: String = "",
		p_usage: int = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
) -> Dictionary:
	var value := {
		"name": p_name,
		"class_name": p_class_name,
		"type": p_type,
		"hint": p_hint,
		"hint_string": p_hint_string,
		"usage": p_usage,
	}
	return value


static func _get_category_dict(p_name: String) -> Dictionary:
	var value := _get_property_dict(
			p_name, TYPE_NIL, PROPERTY_HINT_NONE, "", "", PROPERTY_USAGE_CATEGORY
	)
	return value


static func _get_group_dict(p_name: String, hint_string: String = "") -> Dictionary:
	var value := _get_property_dict(
			p_name, TYPE_NIL, PROPERTY_HINT_NONE, hint_string, "", PROPERTY_USAGE_GROUP
	)
	return value

#endregion Private Methods ------------------------------------------------------------------------
