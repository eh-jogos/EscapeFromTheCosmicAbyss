extends ColorPickerButton

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