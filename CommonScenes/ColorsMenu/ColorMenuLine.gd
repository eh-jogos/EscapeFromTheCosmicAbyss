@tool
extends HBoxContainer

@export var description: String = "": set = _set_description

@export(String, "waves", "tentacles", "laser_eye", "bg_boss", "mid_bg_boss", \
		"final_boss") var category = "waves": set = _set_category

@export var waves_part = "outline" # (String, "outline", "body")
@export var tentacles_part = "outline" # (String, "outline", "body")
@export(String, "outline", "body", "eye", "warning1", "warning2", "warning3", \
		"laser_outline", "laser_core") var laser_eye_part = "outline"
@export var bg_boss_part = "eye" # (String, "eye", "iris", "mouth", "teeth")
@export(String, "outline", "body", "teeth", "eye", "iris") \
		var mid_bg_boss_part = "outline"
@export(String, "outline", "body", "eye", "warning1", "warning2", "warning3", \
		"iris", "tongue", "teeth", "gengiva", "laser_outline", "laser_core") \
		var final_boss_part = "outline"

@export(String, "waves_part", "tentacles_part", "laser_eye_part", "bg_boss_part", \
		"mid_bg_boss_part", "final_boss_part") \
		var selected_part = "waves_part": set = _set_selected_part


var color_picker = null
var description_label = null

func _ready():
	color_picker = get_node("ColorPickerButton")
	description_label = get_node("ColorPickerButton/Description")
	
	var focus_top = "../" + self.get_focus_neighbor(MARGIN_TOP)
	var focus_bottom = "../" + self.get_focus_neighbor(MARGIN_BOTTOM)
	color_picker.set_focus_neighbor(MARGIN_TOP, focus_top)
	color_picker.set_focus_neighbor(MARGIN_BOTTOM, focus_bottom)
	
	self.description = description
	self.category = category
	self.selected_part = selected_part


func enable_buttons() -> void:
	var button_area = $ColorPickerButton/ButtonArea
	color_picker.mouse_filter = Control.MOUSE_FILTER_STOP
	button_area.mouse_filter = Control.MOUSE_FILTER_PASS


func disable_buttons() -> void:
	var button_area = $ColorPickerButton/ButtonArea
	color_picker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button_area.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _set_description(value):
	description = value
	if description_label == null:
		return
	
	description_label.text = description


func _set_category(value):
	category = value
	if Engine.is_editor_hint() or color_picker == null:
		return
	
	color_picker.category = category


func _set_selected_part(value):
	selected_part = value
	if Engine.is_editor_hint() or color_picker == null:
		return
	
	var actual_part = get(selected_part)
	print(actual_part)
	color_picker.selected_part = actual_part
	color_picker.set_current_color()

