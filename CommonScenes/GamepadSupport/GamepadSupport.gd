extends Node
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# export variables
# public variables
# private variables
# onready variables
onready var _prompts_keyboard: ResourcePreloader = get_node("Keyboard")
onready var _prompts_mouse: ResourcePreloader = get_node("Mouse")
onready var _prompts_ps: ResourcePreloader = get_node("Playstation")
onready var _prompts_xbox: ResourcePreloader = get_node("Xbox")
onready var _prompts_nintendo: ResourcePreloader = get_node("Nintendo")

onready var _test_label: Label = get_node("DebugControls/Label")
onready var _test_prompt: TextureRect = get_node("DebugControls/Prompt")

onready var _animator: AnimationPlayer = get_node("AnimationPlayer")

### ---------------------------------------


### Built in Engine Methods ---------------

func _ready():
	Input.connect("joy_connection_changed", self, "_on_Input_joy_connection_changed")
	var device_list: Array = Input.get_connected_joypads()
	for device in device_list:
		print("Joypad Name: %s"%[Input.get_joy_name(device)])
	
	pass


func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed():
		_handle_keyboard_input(event)
	
	if event is InputEventMouseButton and event.is_pressed():
		_handle_mouse_input(event)
	
	if event is InputEventJoypadButton and event.is_pressed():
		_handle_joypad_button_input(event)
	

### ---------------------------------------


### Public Methods ------------------------
### ---------------------------------------


### Private Methods -----------------------
### ---------------------------------------
func _on_Input_joy_connection_changed(device: int, is_connected: bool) -> void:
	print("Input device: %s, is_connected: %s"%[device, is_connected])
	var device_list: Array = Input.get_connected_joypads()
	for device in device_list:
		print("Joypad Name: %s"%[Input.get_joy_name(device)])
	


func _handle_keyboard_input(key_event: InputEventKey) -> void:
	_animator.play("base")
	_show_debug_prompt_or_debug_text(_prompts_keyboard, key_event.scancode)


func _handle_mouse_input(mouse_event: InputEventMouseButton) -> void:
	_animator.play("base")
	_test_prompt.texture = _prompts_mouse.get_resource(str(mouse_event.button_index))


func _handle_joypad_button_input(pad_event: InputEventJoypadButton) -> void:
	_animator.play("base")
	var joypad_prompts = _get_joypad_prompts()
	_show_debug_prompt_or_debug_text(joypad_prompts, pad_event.button_index)


func _show_debug_prompt_or_debug_text(prompts: ResourcePreloader, scancode: int) -> void:
	if prompts.has_resource(str(scancode)):
			_test_prompt.texture = prompts.get_resource(str(scancode))
			_test_label.text = ""
	else:
		_test_prompt.texture = null
		_test_label.text = "%s"%[OS.get_scancode_string(scancode)]


func _get_joypad_prompts() -> ResourcePreloader:
	var joypad_prompts: ResourcePreloader = null
	var joypad_name: String = _get_joypad_name()
	
	match joypad_name:
		"PS":
			joypad_prompts = _prompts_ps
		"Nintendo":
			joypad_prompts = _prompts_nintendo
		"Xbox":
			joypad_prompts = _prompts_xbox
		_:
			joypad_prompts = _prompts_xbox
	
	return joypad_prompts


func _get_joypad_name() -> String:
	var device_name: = ""
	var device_list: Array = Input.get_connected_joypads()
	if device_list.size() > 0:
		device_name = Input.get_joy_name(device_list[0])
	
	if device_name.find("PS") != -1:
		device_name = "PS"
	elif device_name.find("Nintendo") != -1:
		device_name = "Nintendo"
	elif device_name.find("Xbox") != -1 or \
			device_name.find("XBOX") != -1 or \
			device_name.find("X360") != -1:
		device_name = "Xbox"
	
	return device_name
