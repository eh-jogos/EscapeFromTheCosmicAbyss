tool
extends CanvasLayer
# Takes care of identifying Joypads and providing prompt images for registered actions, either
# Joypad prompts if there is any Joypad Connected or Keyboard/Mouse prompts if there isn't any.
# It also provide helper methods to deal with letting the user change Input Maps, auto swaps ui_accept
# and ui_cancel joypad mappings for Switch Controllers, and other stuff. Better used in conjuction
# with PromptInputAction scene to automatize Showing Prompts.
#
# For changing input maps, use listen_input_for public method for an almost automatic experience,
# but there is also change_action_event_type if you want to have your own "Press any key" screen
# or other workflow outside of JoypadSupport. 
#
# To let the user set a prompt skin manually, you'll have to use the set_autodetect and set_chosen_skin
# methods in conjunction
#
# To let users swap ui_accept and ui_cancel manually, in case they want to confirm with Circle and
# cancel with Cross like in eastern rpgs and games for example, just use swap_ui_accept_and_cancel
# passing true when the user chooses this option. It will override the automatic swapping. 


### Member Variables and Dependencies -----
# signals 
# Kept this signals separate instead of only "_changed" so that both events can be used if needed
signal joypad_connected
signal joypad_disconnected
signal joypad_manually_changed
signal input_entered(input_map_action)
signal input_remapped

# enums
enum JoyPads {
	NO_JOYPAD,
	XBOX,
	PLAYSTATION,
	NINTENDO,
	UNINDENTIFIED,
}

enum Modes {
	NONE,
	KEYBOARD_AND_MOUSE,
	JOYPAD,
}

# constants
# export variables
# public variables
var joypad_type: int = JoyPads.NO_JOYPAD
var was_ui_accept_manually_swapped: = false

onready var prompts_keyboard: ResourcePreloader = get_node("Keyboard")
onready var prompts_mouse: ResourcePreloader = get_node("Mouse")
onready var prompts_joypad: ResourcePreloader = get_node("Xbox")

# private variables
var _listen_mode = Modes.NONE

var _accept_event: = JS_InputMapAction.new("ui_accept", 
		JS_InputMapAction.Types.JOYPAD_BUTTON, JOY_XBOX_A)
var _cancel_event: = JS_InputMapAction.new("ui_cancel", 
		JS_InputMapAction.Types.JOYPAD_BUTTON, JOY_XBOX_B)
var _swapped_accept_event = JS_InputMapAction.new("ui_accept", 
		JS_InputMapAction.Types.JOYPAD_BUTTON, JOY_DS_A)
var _swapped_cancel_event = JS_InputMapAction.new("ui_cancel", 
		JS_InputMapAction.Types.JOYPAD_BUTTON, JOY_DS_B)

onready var _joypad_identifier: JS_JoypadIdentifier = get_node("JoypadIdentifier")
onready var _animator: AnimationPlayer = get_node("AnimationPlayer")

### ---------------------------------------


### Built in Engine Methods ---------------

func _ready() -> void:
	if Engine.editor_hint:
		$BackPanel.hide()
	
	set_process_input(false)
	Input.connect("joy_connection_changed", self, "_on_Input_joy_connection_changed")
	var input_devices = Input.get_connected_joypads()
	if input_devices.size() > 0:
		_set_joypad_type(input_devices[0], true)


func _input(event) -> void:
	if _listen_mode == Modes.NONE:
		set_process_input(false)
		return 
	
	var input_code: int = -1
	var event_type: int = -1
	
	if _listen_mode == Modes.JOYPAD:
		if event is InputEventJoypadButton:
			input_code = event.button_index
			event_type = JS_InputMapAction.Types.JOYPAD_BUTTON
		elif event is InputEventJoypadMotion:
			input_code = event.axis
			event_type = JS_InputMapAction.Types.JOYPAD_AXIS
	elif _listen_mode == Modes.KEYBOARD_AND_MOUSE:
		if event is InputEventKey:
			input_code = event.scancode
			event_type = JS_InputMapAction.Types.KEY
		elif event is InputEventMouseButton:
			input_code = event.button_index
			event_type = JS_InputMapAction.Types.MOUSE
	
	get_viewport().set_input_as_handled()
	
	if input_code != -1:
		emit_signal("input_entered", {event_type = event_type, input_code = input_code})


### ---------------------------------------


### Public Methods ------------------------
func listen_input_for(action_name: String, mode: int):
	_listen_mode = mode
	
	set_process_input(true)
	var new_input_dictionary: Dictionary = yield(_listen_input(), "completed")
	set_process_input(false)
	
	var new_input_map_action: = JS_InputMapAction.new(action_name, 
			new_input_dictionary.event_type, new_input_dictionary.input_code)
	change_action_event_type(new_input_map_action)


func change_action_event_type(input_map_action: JS_InputMapAction):
	var action_name = input_map_action.get_action_name()
	var event = input_map_action.event
	_erase_all_event_type_from(action_name, event)
	InputMap.action_add_event(action_name, event)
	emit_signal("input_remapped")
	var event_list = InputMap.get_action_list(action_name)
	print("Event List: %s"%[event_list])


func change_profile_to(profile_name: String) -> void:
	var profiles = $ControlProfiles
	if not profiles.has_profile(profile_name):
		return
	
	for input_map_action in profiles.get(profile_name):
		change_action_event_type(input_map_action)


func set_autodetect_to(on_off: bool) -> void:
	_joypad_identifier._set_autodetect_to(on_off)
	if get_autodetect():
		var input_devices = Input.get_connected_joypads()
		if input_devices.size() > 0:
			_set_joypad_type(input_devices[0], true)


func get_autodetect() -> bool:
	return _joypad_identifier._get_autodetect()


func set_chosen_skin(skin: int) -> void:
	_joypad_identifier._set_chosen_skin(skin)
	update_joypad_prompts_manually()


func get_chosen_skin() -> int:
	return _joypad_identifier._get_chosen_skin()


func update_joypad_prompts_manually() -> void:
	joypad_type = _joypad_identifier.get_joypad_type("")
	_handle_swap_ui_accept_cancel()
	prompts_joypad = _joypad_identifier.get_joypad_prompts()
	emit_signal("joypad_manually_changed")


func swap_ui_accept_and_cancel(was_manually_swapped: = false):
	if are_ui_accept_and_cancel_swapped():
		change_action_event_type(_accept_event)
		change_action_event_type(_cancel_event)
	else:
		change_action_event_type(_swapped_accept_event)
		change_action_event_type(_swapped_cancel_event)
	
	if was_manually_swapped != was_ui_accept_manually_swapped:
		emit_signal("joypad_manually_changed")
	
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
func _listen_input() -> Dictionary:
	_animator.play("press_button")
	yield(_animator, "animation_finished")
	var input_dictionary: Dictionary = yield(self, "input_entered")
	_animator.play("base")
	return input_dictionary


func _set_joypad_type(device: int, is_connected: bool) -> void:
	if is_connected:
		var device_name: = Input.get_joy_name(device)
		joypad_type = _joypad_identifier.get_joypad_type(device_name)
		_handle_swap_ui_accept_cancel()
		prompts_joypad = _joypad_identifier.get_joypad_prompts()
		emit_signal("joypad_connected")
	else:
		joypad_type = JoyPads.NO_JOYPAD
		emit_signal("joypad_disconnected")


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


func _handle_swap_ui_accept_cancel():
	var is_auto_swapped: = are_ui_accept_and_cancel_swapped() and not was_ui_accept_manually_swapped
	var is_user_swapped: = are_ui_accept_and_cancel_swapped() and was_ui_accept_manually_swapped 
	var should_be_autoswapped: = not are_ui_accept_and_cancel_swapped() and not was_ui_accept_manually_swapped
	var should_be_user_swapped: = not are_ui_accept_and_cancel_swapped() and was_ui_accept_manually_swapped
	match joypad_type:
		JoyPads.NINTENDO:
			if should_be_autoswapped:
				swap_ui_accept_and_cancel()
			elif is_user_swapped:
				swap_ui_accept_and_cancel(was_ui_accept_manually_swapped)
		JoyPads.PLAYSTATION, JoyPads.XBOX, JoyPads.UNINDENTIFIED:
			if is_auto_swapped:
				swap_ui_accept_and_cancel()
			elif should_be_user_swapped:
				swap_ui_accept_and_cancel(was_ui_accept_manually_swapped)
		JoyPads.NO_JOYPAD:
			pass
		_:
			push_error("Undefined Joypad: %s"%[joypad_type])
			assert(false)


func _erase_all_event_type_from(action_name: String, new_event: InputEvent) -> void:
	var event_list = InputMap.get_action_list(action_name)
	for event in event_list:
		if event is InputEventKey and new_event is InputEventKey:
			InputMap.action_erase_event(action_name, event)
		elif event is InputEventMouseButton and new_event is InputEventMouseButton:
			InputMap.action_erase_event(action_name, event)
		elif event is InputEventJoypadButton and new_event is InputEventJoypadButton:
			InputMap.action_erase_event(action_name, event)
		elif event is InputEventJoypadMotion and new_event is InputEventJoypadMotion:
			InputMap.action_erase_event(action_name, event)


func _on_Input_joy_connection_changed(device: int, is_connected: bool) -> void:
	#print("Input device: %s, is_connected: %s"%[device, is_connected])
	_set_joypad_type(device, is_connected)
