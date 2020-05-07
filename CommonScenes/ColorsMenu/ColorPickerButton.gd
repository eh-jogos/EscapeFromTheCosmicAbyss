extends ColorPickerButton

var category = ""
var selected_part = ""

onready var back_panel = self.get_popup()
onready var color_picker_container = back_panel.get_child(0)

onready var color_choose_line = color_picker_container.get_child(0)
onready var saturation_value_square = color_choose_line.get_child(0)
onready var hue_slider = color_choose_line.get_child(1)

onready var color_preview_line = color_picker_container.get_child(1)
onready var color_preview = color_preview_line.get_child(0)
onready var color_pick_button = color_preview_line.get_child(1)

onready var separator1 = color_picker_container.get_child(3)
onready var separator2 = color_picker_container.get_child(5)

onready var sliders_container = color_picker_container.get_child(4)
onready var red_slider_line = sliders_container.get_child(0)
onready var green_slider_line = sliders_container.get_child(1)
onready var blue_slider_line = sliders_container.get_child(2)
onready var slider_separator_line = sliders_container.get_child(3)
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
	Global.connect("reset_color_pickers", self, "_on_Global_reset_color_pickers")

func set_current_color():
	color = Global.savedata.colors[category][selected_part]


func _on_color_changed(color):
	Global.savedata.colors[category][selected_part] = color
	
	get_tree().call_group("interactive_color", "colors_changed")


func _on_Global_reset_color_pickers():
	set_current_color()


func _on_popup_hide():
	_button_area.mouse_filter = Control.MOUSE_FILTER_STOP
	$Cooldown.start()
	yield(get_tree(), "idle_frame")
	
	SoundManager.play_sfx("Change")
	
	self.grab_focus()


func _on_focus_entered():
	var description = get_node("Description")
	description.add_color_override("font_color", Color("ffffff"))


func _on_focus_exited():
	SoundManager.play_sfx("Select")
	var description = get_node("Description")
	description.add_color_override("font_color", Color("00f5ff"))


func _on_ButtonArea_mouse_enter():
	self.grab_focus()


func _on_ColorPickerButton_gui_input( event ):
	if event.is_action_pressed("ui_right"):
		Global.emit_signal("navigated_to_right")
	elif event.is_action_pressed("ui_left"):
		Global.emit_signal("navigated_to_left")


func _process(_delta):
	if not back_panel.visible:
		return
	
	var has_color_changed = false
	
	has_color_changed = _handle_color_input("hue")
	has_color_changed = _handle_color_input("saturation")
	has_color_changed = _handle_color_input("value")
	
	if has_color_changed:
		emit_signal("color_changed", color)
	
	if Input.is_action_just_pressed("ui_accept"):
		back_panel.hide()


func _handle_color_input(hsv_option: String) -> bool:
	var has_color_changed = false
	var action_up: String = ""
	var action_down: String = ""
	var color_string: String = ""
	match hsv_option:
		"hue":
			action_up = "color_hue_down"
			action_down = "color_hue_up"
			color_string = "h"
		"saturation":
			action_up = "color_saturation_up"
			action_down = "color_saturation_down"
			color_string = "s"
		"value":
			action_up = "color_value_up"
			action_down = "color_value_down"
			color_string = "v"
		_:
			push_warning("Unindentified option: %s | Must be one of"
					+ "hue, saturation or value"%[hsv_option])
			return false
	
	has_color_changed = true
	
	if Input.is_action_pressed(action_up):
		var strength = Input.get_action_strength(action_up)
		color[color_string] = clamp(color[color_string] + 0.01 * abs(strength), 0.0, 1.0)
		print("color.%s changed: %s | strength: %s"%[color_string, color[color_string], strength])
	elif Input.is_action_pressed(action_down):
		var strength = Input.get_action_strength(action_down)
		color[color_string] = clamp(color[color_string] - 0.01 * abs(strength), 0.0, 1.0)
		print("color.%s changed: %s | strength: %s"%[color_string, color[color_string], strength])
	
	
	return has_color_changed


func _on_Cooldown_timeout():
	#print("Active Again")
	_button_area.mouse_filter = Control.MOUSE_FILTER_PASS


func _set_color_picker_appearence() -> void:
	color_preview_line.hide()
	sliders_container.hide()
	presets_line.hide()
	separator1.hide()
	separator2.hide()
	
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
	slider_separator_line.name = "SeparatorLine"
	hsv_mode_option.name = "HSVModeOption"
	raw_mode_option.name = "RawModeOption"
	toggle_output_button.name = "ToggleOutputFormatButton"
	hex_code_line_edit.name = "HexCodeLineEdit"
	presets_line.name = "PresetsLine"
