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

const BEAT_GROUP_PREFIX := "on_beat_"
const HALF_GROUP_PREFIX := "on_half_"

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

@export_storage var beats: Dictionary = {
	"none": 0,
	"tentacles": 0,
	"double_tentacle": 0,
	"triple_tentacle": 0,
	"wall_tentacle": 0,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}:
	set(value):
		beats = value
		_sanitize_obstacle_keys(beats)

@export_storage var half_beats: Dictionary = {
	"none": 0,
	"tentacles": 0,
	"double_tentacle": 0,
	"triple_tentacle": 0,
	"wall_tentacle": 0,
	"laser_eye": 0,
	"shield_up": 0,
	"ammo_up": 0
}:
	set(value):
		half_beats = value
		_sanitize_obstacle_keys(half_beats)

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

#endregion Built in Engine Methods ----------------------------------------------------------------


#region Public Methods ----------------------------------------------------------------------------


func validate_level() -> void:
	assert(not title.is_empty(), "Title for level must not be empty | @:%s"%[resource_path])
	var total_beats: int = beats.values().reduce(_sum_array)
	var total_halfs: int = half_beats.values().reduce(_sum_array)
	assert(
		total_beats == total_halfs, 
		"Amount of obstacles in beats must be the same as in half beats"
	)
	assert(
		scream_countdowns.size() == scream_sequence_beats.size() 
		and scream_countdowns.size() == scream_sequence_halfs.size(),
		"We need to have one array of beats/half beats sequences per countdown. "\
		+"| Countdowns: %s, beats sequences: %s, half beats sequences: %s"%[
			scream_countdowns.size(), scream_sequence_beats.size(), scream_sequence_halfs.size()
		]
	)
	for index in scream_countdowns.size():
		assert(
			scream_sequence_beats[index].size() == scream_sequence_halfs[index].size(),
			"For a same scream sequence, size of beats and half beats must be equal."
	)


#endregion Public Methods -------------------------------------------------------------------------


#region Private Methods ---------------------------------------------------------------------------

func _sanitize_obstacle_keys(p_dict: Dictionary) -> void:
	var valid_keys := ObstacleTypes.keys().map(_map_to_snake_case)
	for key in p_dict.keys():
		if not key in valid_keys:
			p_dict.erase(key)
	
	for key in valid_keys:
		if not p_dict.has(key):
			p_dict[key] = 0

#endregion Private Methods ------------------------------------------------------------------------

#region Advanced Exports --------------------------------------------------------------------------

func _get_property_list() -> Array[Dictionary]:
	var value: Array[Dictionary] = []
	var ordered_keys := ObstacleTypes.keys().map(_map_to_snake_case)
	
	value.append(_get_group_dict("On Beat Obstacles", BEAT_GROUP_PREFIX))
	_add_obstacles_properties_to(value, ordered_keys, BEAT_GROUP_PREFIX)
	value.append(
		_get_property_dict(
			"%s%s"%[BEAT_GROUP_PREFIX, "total"],TYPE_INT,PROPERTY_HINT_NONE,
			"", "", PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY
		)
	)
	
	value.append(_get_group_dict("On Half Beat Obstacles", HALF_GROUP_PREFIX))
	_add_obstacles_properties_to(value, ordered_keys, HALF_GROUP_PREFIX)
	value.append(
		_get_property_dict(
			"%s%s"%[HALF_GROUP_PREFIX, "total"],TYPE_INT,PROPERTY_HINT_NONE,
			"", "", PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY
		)
	)
	
	_add_boss_settings_properties_to(value)
	return value


func _get(property: StringName) -> Variant:
	var value: Variant = null
	
	if property.begins_with(BEAT_GROUP_PREFIX):
		var sanitized_key := property.trim_prefix(BEAT_GROUP_PREFIX)
		if sanitized_key == "total":
			value = beats.values().reduce(_sum_array)
		else:
			value = beats[sanitized_key]
	elif property.begins_with(HALF_GROUP_PREFIX):
		var sanitized_key := property.trim_prefix(HALF_GROUP_PREFIX)
		if sanitized_key == "total":
			value = half_beats.values().reduce(_sum_array)
		else:
			value = half_beats[sanitized_key]
	
	return value


func _set(property: StringName, value: Variant) -> bool:
	var has_changed := false
	
	if property.begins_with(BEAT_GROUP_PREFIX):
		var sanitized_key := property.trim_prefix(BEAT_GROUP_PREFIX)
		beats[sanitized_key] = value
	elif property.begins_with(HALF_GROUP_PREFIX):
		var sanitized_key := property.trim_prefix(HALF_GROUP_PREFIX)
		if sanitized_key in half_beats:
			half_beats[sanitized_key] = value
	
	return has_changed


func _property_can_revert(property: StringName) -> bool:
	const BOSS_PROPERTIES := [
		"is_boss_level", "boss_type", "has_boss_laser", "laser_countdowns", "boss_animations",
		"boss_animations_countdowns", "danger_durations", "has_boss_scream",
		"scream_sequence_beats", "scream_sequence_halfs"
	]
	var value := false
	
	if property.begins_with(BEAT_GROUP_PREFIX) or property.begins_with(HALF_GROUP_PREFIX):
		value = true
	elif property in BOSS_PROPERTIES:
		value = true
	
	return value


func _property_get_revert(property: StringName) -> Variant:
	var value: Variant = null
	
	if property.begins_with(BEAT_GROUP_PREFIX):
		value = 0
	elif property.begins_with(HALF_GROUP_PREFIX):
		value = 0
	else:
		match property:
			"is_boss_level", "has_boss_laser", "has_boss_scream":
				value = false
			"boss_type":
				value = BossTypes.NONE
			"laser_countdowns", "boss_animations", "boss_animations_countdowns",\
			"danger_durations","scream_sequence_beats","scream_sequence_halfs":
				value = []
	
	return value


func _sum_array(p_total: int, p_current: int) -> int:
	return p_total + p_current


func _map_to_snake_case(p_string: String) -> String:
	return p_string.to_snake_case()


func _add_obstacles_properties_to(
		property_list: Array[Dictionary], 
		p_from: Array, 
		p_prefix: String
) -> void:
	for key in p_from:
		var prop_dict := _get_property_dict(
				"%s%s"%[p_prefix, key], 
				TYPE_INT, 
				PROPERTY_HINT_RANGE, 
				"0,1,1,or_greater", 
				"", 
				PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED
		)
		property_list.append(prop_dict)


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
					"scream_countdowns",
					TYPE_ARRAY,
					PROPERTY_HINT_ARRAY_TYPE, 
					"int"
				)
			)
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

#endregion Advanced Exports -----------------------------------------------------------------------
