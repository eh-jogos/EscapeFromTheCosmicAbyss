extends ColorPickerButton

var category = ""
var selected_part = ""

# fix for using Global on tool
var Global = null
var SoundManager = null

onready var back_panel = self.get_popup()
onready var color_picker_container = back_panel.get_child(0)

onready var color_choose_line = color_picker_container.get_child(0)
onready var saturation_value_square = color_choose_line.get_child(0)
onready var hue_slider = color_choose_line.get_child(1)

onready var color_preview_line = color_picker_container.get_child(1)
onready var color_preview = color_preview_line.get_child(0)
onready var color_pick_button = color_preview_line.get_child(1)

onready var sliders_container = color_picker_container.get_child(4)
onready var red_slider_line = sliders_container.get_child(0)
onready var green_slider_line = sliders_container.get_child(1)
onready var blue_slider_line = sliders_container.get_child(2)
onready var separator_line = sliders_container.get_child(3)
onready var options_line = sliders_container.get_child(4)
onready var hsv_mode_option = options_line.get_child(0)
onready var raw_mode_option = options_line.get_child(1)
onready var toggle_output_button = options_line.get_child(2)
onready var hex_code_line_edit = options_line.get_child(3)

onready var presets_line = color_picker_container.get_child(7)

onready var _button_area : Button = get_node("ButtonArea")

func _ready():
	_name_color_picker_elements()
	_set_color_picker_appearence()
	
	connect("color_changed", self, "_on_color_changed")
	connect("focus_entered", self, "_on_focus_entered")
	connect("focus_exited", self, "_on_focus_exited")
	back_panel.connect("popup_hide", self, "_on_popup_hide")
	
	if not Engine.is_editor_hint():
		Global = get_node("/root/Global")
		SoundManager = get_node("/root/SoundManager")


func set_current_color():
	if Engine.is_editor_hint():
		return
	
	if Global:
		color = Global.savedata.colors[category][selected_part]


func _on_color_changed(color):
	if Engine.is_editor_hint():
		return
	
	if Global:
		Global.savedata.colors[category][selected_part] = color
	
	get_tree().call_group("interactive_color", "colors_changed")


func _on_popup_hide():
	_button_area.mouse_filter = Control.MOUSE_FILTER_STOP
	$Cooldown.start()
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


func _on_ColorPickerButton_gui_input( event ):
	if not Global:
		return
	
	if event.is_action_pressed("ui_right"):
		Global.emit_signal("navigated_to_right")
	elif event.is_action_pressed("ui_left"):
		Global.emit_signal("navigated_to_left")


func _set_color_picker_appearence() -> void:
	color_preview_line.hide()
	red_slider_line.hide()
	green_slider_line.hide()
	blue_slider_line.hide()
	separator_line.hide()
	hsv_mode_option.hide()
	raw_mode_option.hide()
	toggle_output_button.hide()
	presets_line.hide()
	
	hue_slider.set_custom_minimum_size(Vector2(40,0))
	back_panel.rect_min_size = Vector2.ONE * 400


func _name_color_picker_elements() -> void:
	# I'm doing this just to help with debugging
	back_panel.name = "BackPanel"
	color_picker_container.name = "ColorPickerContainer"
	color_choose_line.name = "ColorChooseLine"
	saturation_value_square.name = "SVSquare"
	hue_slider.name = "HueSlider"
	color_preview_line.name = "ColorPreviewLine"
	color_preview.name = "ColorPreview"
	color_pick_button.name = "ColorPickButton"
	sliders_container.name = "SlidersContainer"
	red_slider_line.name = "RedSliderLine"
	green_slider_line.name = "GreenSliderLine"
	blue_slider_line.name = "BlueSliderLine"
	separator_line.name = "SeparatorLine"
	hsv_mode_option.name = "HSVModeOption"
	raw_mode_option.name = "RawModeOption"
	toggle_output_button.name = "ToggleOutputFormatButton"
	hex_code_line_edit.name = "HexCodeLineEdit"
	presets_line.name = "PresetsLine"


func _on_Cooldown_timeout():
	print("Active Again")
	_button_area.mouse_filter = Control.MOUSE_FILTER_PASS
	
