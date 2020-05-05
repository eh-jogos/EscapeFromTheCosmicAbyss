extends ColorPickerButton
tool

var category = ""
var selected_part = ""

# fix for using Global on tool
var Global = null
var SoundManager = null

onready var back_panel = get_child(0)
onready var color_picker_container = back_panel.get_child(0)

onready var color_preview_line = color_picker_container.get_child(0)
onready var color_preview = color_preview_line.get_child(0)
onready var color_pick_button = color_preview_line.get_child(1)

onready var color_choose_line = color_picker_container.get_child(1)
onready var saturation_value_square = color_choose_line.get_child(0)
onready var hue_slider = color_choose_line.get_child(2)

onready var sliders_container = color_picker_container.get_child(4)
onready var red_slider_line = sliders_container.get_child(0)
onready var green_slider_line = sliders_container.get_child(1)
onready var blue_slider_line = sliders_container.get_child(2)
onready var separator_line = sliders_container.get_child(3)
onready var options_line = sliders_container.get_child(4)
onready var raw_mode_option = options_line.get_child(0)
onready var copy_button = options_line.get_child(1)
onready var hex_code_line_edit = options_line.get_child(2)

onready var presets_line = color_picker_container.get_child(5)

func _ready():
	color_preview_line.hide()
	red_slider_line.hide()
	green_slider_line.hide()
	blue_slider_line.hide()
	separator_line.hide()
	raw_mode_option.hide()
	copy_button.hide()
	
	hue_slider.set_expand(true)
	hue_slider.set_custom_minimum_size(Vector2(40,0))
	
	connect("color_changed", self, "_on_color_changed")
	connect("focus_entered", self, "_on_focus_entered")
	connect("focus_exited", self, "_on_focus_exited")
	back_panel.connect("modal_closed", self, "_on_modal_closed")
	
	if not get_tree().is_editor_hint():
		Global = get_node("/root/Global")
		SoundManager = get_node("/root/SoundManager")


func set_current_color():
	if not Engine.has_singleton("Global"):
		return
	
	if Global:
		color = Global.savedata.colors[category][selected_part]


func _on_color_changed(color):
	if not Engine.has_singleton("Global"):
		return
	
	if Global:
		Global.savedata.colors[category][selected_part] = color
	
	get_tree().call_group("interactive_color", "colors_changed")


func _on_modal_closed():
	yield(get_tree(), "idle_frame")
	
	if SoundManager:
		SoundManager.play_sfx("Change")
	
	self.grab_focus()


func _on_focus_entered():
	var description = get_node("Description")
	description.add_color_override("font_color", Color("ffffff"))


func _on_focus_exited():
	if SoundManager:
		SoundManager.play_sfx("Select")
	var description = get_node("Description")
	description.add_color_override("font_color", Color("00f5ff"))


func _on_ButtonArea_mouse_enter():
	self.grab_focus()


func _on_ColorPickerButton_gui_input( ev ):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	if not Global:
		return
	
	if ev.is_action_pressed("ui_right"):
		Global.emit_signal("navigated_to_right")
	elif ev.is_action_pressed("ui_left"):
		Global.emit_signal("navigated_to_left")

