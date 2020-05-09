extends CanvasLayer
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# Kept this signals separate so that both events can be used if needed
signal joypad_connected
signal joypad_disconnected

# enums
enum JoyPads {
	NO_JOYPAD,
	XBOX,
	PLAYSTATION,
	NINTENDO,
	UNINDENTIFIED,
}

enum EventTypes {
	KEY,
	MOUSE,
	JOYPAD_BUTTON,
	JOYPAD_AXIS,
}

# constants
# export variables
# public variables
var joypad_type: int = JoyPads.NO_JOYPAD
var was_ui_accept_manually_swapped: = false

# private variables
# onready variables
onready var prompts_keyboard: ResourcePreloader = get_node("Keyboard")
onready var prompts_mouse: ResourcePreloader = get_node("Mouse")
onready var prompts_joypad: ResourcePreloader = get_node("Xbox")

onready var _prompts_ps: ResourcePreloader = get_node("Playstation")
onready var _prompts_xbox: ResourcePreloader = get_node("Xbox")
onready var _prompts_nintendo: ResourcePreloader = get_node("Nintendo")

onready var _animator: AnimationPlayer = get_node("AnimationPlayer")

### ---------------------------------------


### Built in Engine Methods ---------------

func _ready():
	Input.connect("joy_connection_changed", self, "_on_Input_joy_connection_changed")
	var input_devices = Input.get_connected_joypads()
	if input_devices.size() > 0:
		_set_joypad_type(input_devices[0], true)

### ---------------------------------------


### Public Methods ------------------------
func change_action_event_type(action_name: String, event_type: int, new_input_code:int):
	_erase_all_event_type_from(action_name, event_type)
	var new_event = _get_new_event_of_type(event_type, new_input_code)
	InputMap.action_add_event(action_name, new_event)
	#Save this somewhere? send update signal to update al current Prompts?


func swap_ui_accept_and_cancel(was_manually_swapped: = false):
	if are_ui_accept_and_cancel_swapped():
		change_action_event_type("ui_accept", EventTypes.JOYPAD_BUTTON, JOY_XBOX_A)
		change_action_event_type("ui_cancel", EventTypes.JOYPAD_BUTTON, JOY_XBOX_B)
	else:
		change_action_event_type("ui_accept", EventTypes.JOYPAD_BUTTON, JOY_DS_A)
		change_action_event_type("ui_cancel", EventTypes.JOYPAD_BUTTON, JOY_DS_B)
	
	was_ui_accept_manually_swapped = was_manually_swapped


func are_ui_accept_and_cancel_swapped() -> bool:
	var are_swapped: = false
	var event_list = InputMap.get_action_list("ui_accept")
	
	for event in event_list:
		if event is InputEventJoypadButton and event.button_index == JOY_DS_A:
			are_swapped = true
			break
	
	return are_swapped


func get_joypad_button_prompt_for(button_index: String) -> Texture:
	var prompt_texture: Texture = _get_prompt_for(prompts_joypad, button_index)
	return prompt_texture


func get_keyboard_prompt_for(scancode: String) -> Texture:
	var prompt_texture: Texture = _get_prompt_for(prompts_keyboard, scancode)
	return prompt_texture


func get_mouse_prompt_for(button_index: String) -> Texture:
	var prompt_texture: Texture = _get_prompt_for(prompts_mouse, button_index)
	return prompt_texture

### ---------------------------------------


### Private Methods -----------------------
### ---------------------------------------
func _set_joypad_type(device: int, is_connected: bool) -> void:
	if is_connected:
		joypad_type = _get_joypad_type(device)
		prompts_joypad = _get_joypad_prompts()
		emit_signal("joypad_connected")
	else:
		joypad_type = JoyPads.NO_JOYPAD
		emit_signal("joypad_disconnected")


func _get_joypad_prompts() -> ResourcePreloader:
	var joypad_prompts: ResourcePreloader = null
	
	match joypad_type:
		JoyPads.PLAYSTATION:
			joypad_prompts = _prompts_ps
		JoyPads.NINTENDO:
			joypad_prompts = _prompts_nintendo
		JoyPads.XBOX, JoyPads.UNINDENTIFIED:
			joypad_prompts = _prompts_xbox
		_:
			if joypad_type == JoyPads.NO_JOYPAD:
				push_error("There should be no joypad, what are you doing here? Or if there" \
					+ "is a joypad, what AM I doing here?")
			else:
				push_warning("unregistered joypad type (%s), defaulting to xbox"%[
					JoyPads.keys()[joypad_type]])
			joypad_prompts = _prompts_xbox
	
	return joypad_prompts


func _get_joypad_type(device: int) -> int:
	var device_name: = Input.get_joy_name(device)
	var type = JoyPads.UNINDENTIFIED
	
	if device_name.find("PS") != -1:
		type = JoyPads.PLAYSTATION
		if are_ui_accept_and_cancel_swapped() and not was_ui_accept_manually_swapped:
			swap_ui_accept_and_cancel()
	elif device_name.find("Nintendo") != -1:
		type = JoyPads.NINTENDO
		if not are_ui_accept_and_cancel_swapped() and not was_ui_accept_manually_swapped:
			swap_ui_accept_and_cancel()
	elif device_name.find("Xbox") != -1 or \
		device_name.find("XBOX") != -1 or \
		device_name.find("X360") != -1:
		type = JoyPads.XBOX
		if are_ui_accept_and_cancel_swapped() and not was_ui_accept_manually_swapped:
			swap_ui_accept_and_cancel()
	
	return type


func _get_prompt_for(loader: ResourcePreloader, index: String) -> Texture:
	var texture: Texture = StreamTexture.new()
	if loader.has_resource(index):
		texture = loader.get_resource(index)
		return texture
	else:
		push_error("Can't find texture for index %s in %s"%[
			index,
			loader.name
		])
		assert(false)
		return texture


func _erase_all_event_type_from(action_name: String, event_type: int) -> void:
	var event_list = InputMap.get_action_list(action_name)
	for event in event_list:
		match event_type:
			EventTypes.KEY:
				if event is InputEventKey:
					InputMap.action_erase_event(action_name, event)
			EventTypes.MOUSE:
				if event is InputEventMouseMotion:
					InputMap.action_erase_event(action_name, event)
			EventTypes.JOYPAD_BUTTON:
				if event is InputEventJoypadButton:
					InputMap.action_erase_event(action_name, event)
			EventTypes.JOYPAD_AXIS:
				if event is InputEventJoypadMotion:
					InputMap.action_erase_event(action_name, event)
			_:
				push_error("Invalid event_type: %s"%[event_type])
				assert(false)


func _get_new_event_of_type(event_type: int, new_input_code:int) -> InputEvent:
	var new_event: InputEvent = null
	
	match event_type:
		EventTypes.KEY:
			new_event = _get_new_key_event(new_input_code)
		EventTypes.MOUSE:
			new_event = _get_new_mouse_button_event(new_input_code)
		EventTypes.JOYPAD_BUTTON:
			new_event = _get_new_joypad_button_event(new_input_code)
		EventTypes.JOYPAD_AXIS:
			new_event = _get_new_joypad_axis_event(new_input_code)
		_:
			push_error("Invalid event_type: %s"%[event_type])
			assert(false)
	
	return new_event


func _get_new_key_event(scancode: int) -> InputEventKey:
	var new_event: = InputEventKey.new()
	new_event.scancode = scancode
	return new_event


func _get_new_mouse_button_event(button_index: int) -> InputEventMouseButton:
	var new_event: = InputEventMouseButton.new()
	new_event.button_index = button_index
	return new_event


func _get_new_joypad_button_event(button_index: int) -> InputEventJoypadButton:
	var new_event: = InputEventJoypadButton.new()
	new_event.button_index = button_index
	return new_event


func _get_new_joypad_axis_event(axis: int) -> InputEventJoypadMotion:
	var new_event: = InputEventJoypadMotion.new()
	new_event.axis = axis
	return new_event


func _on_Input_joy_connection_changed(device: int, is_connected: bool) -> void:
	#print("Input device: %s, is_connected: %s"%[device, is_connected])
	_set_joypad_type(device, is_connected)
