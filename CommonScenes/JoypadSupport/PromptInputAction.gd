extends MarginContainer
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# export variables
# public variables
# private variables
var _input_action: String = ""
var _event_keyboard: String = ""
var _event_mouse: String = ""
var _event_joybutton: String = ""
var _event_joyaxis: String = ""

# onready variables
onready var _prompt: TextureRect = get_node("Prompt")
onready var _fallback: Label = get_node("Fallback")

### ---------------------------------------


### Built in Engine Methods ---------------

func _ready():
	_input_action = name.lstrip("Prompt_")
	
	if get_tree().current_scene == self:
		randomize()
		var actions_list: =InputMap.get_actions()
		var random_index = randi() % actions_list.size()
		_input_action = actions_list[random_index]
	
	_setup(_input_action)
	
	if not get_tree().get_root().has_node("/root/JoypadSupport"):
		push_error("Please register the JoypadSupport scene as an autoload on Project Settings " + \
				"with JoypadSupport as name.Or change the code below to point to where " + \
				"JoypadSupport is or it's equivalent.1")
		assert(false)
	
	# Both call backs do the same thing here, but kept them separate to facilitade customization
	# or expansion of each event separately
	JoypadSupport.connect("joypad_connected", self, "_on_JoypadSupport_joypad_connected")
	JoypadSupport.connect("joypad_disconnected", self, "_on_JoypadSupport_joypad_disconnected")

### ---------------------------------------


### Public Methods ------------------------
### ---------------------------------------


### Private Methods -----------------------
func _reset_event_variables():
	_event_keyboard = ""
	_event_mouse = ""
	_event_joybutton = ""
	_event_joyaxis = ""


func _setup(input_action) -> void:
	_reset_event_variables()
	var actions_list: = InputMap.get_actions()
	if actions_list.has(input_action):
		_setup_event_variables()
		_setup_prompt_appearence()
	else:
		push_error("Couldn't find %s in input map list: %s"%[_input_action, actions_list])
		assert(false)


func _setup_event_variables() -> void:
	var event_list: = InputMap.get_action_list(_input_action)
	if event_list.size() > 0:
		for event in event_list:
			if event is InputEventKey and _event_keyboard == "":
				_event_keyboard = str((event as InputEventKey).scancode)
			elif event is InputEventMouseButton and _event_mouse == "":
				_event_mouse = str((event as InputEventMouseButton).button_index)
			elif event is InputEventJoypadButton and _event_joybutton == "":
				_event_joybutton = str((event as InputEventJoypadButton).button_index)
			elif event is InputEventJoypadMotion and _event_joyaxis == "":
				_event_joyaxis = str((event as InputEventJoypadMotion).axis)
	else:
		push_error("input map action has no events in it!" + \
				" Register events for it in the Project Settings or through code")
		assert(false)


func _setup_prompt_appearence() -> void:
	var success: = false
	success = _set_prompt_texture()
	
	if not success:
		success = _set_fallback_label()
	
	if not success:
		_push_fallback_failed_error()


func _set_prompt_texture() -> bool:
	var success: = false
	if JoypadSupport.joypad_type == JoypadSupport.JoyPads.NO_JOYPAD:
		if _event_keyboard != "":
			success = _set_prompt_for(_event_keyboard)
		elif _event_mouse != "":
			success = _set_prompt_for(_event_mouse)
	else:
		if _event_joybutton != "":
			success = _set_prompt_for(_event_joybutton)
		elif _event_joyaxis != "":
			success = _set_prompt_for(_event_joyaxis)
		elif _event_keyboard != "":
			success = _set_prompt_for(_event_keyboard)
		elif _event_mouse != "":
			success = _set_prompt_for(_event_mouse)
	
	return success


func _set_prompt_for(string_index: String) -> bool:
	var prompt_texture: Texture =  _get_prompt_texture_for(string_index)
	var success = prompt_texture.resource_path != ""
	
	if success:
		_prompt.texture = prompt_texture
	
	return success


func _get_prompt_texture_for(string_index: String) -> Texture:
	var prompt_texture: = StreamTexture.new()
	
	match string_index:
		_event_keyboard:
			prompt_texture = JoypadSupport.get_keyboard_prompt_for(_event_keyboard)
		_event_mouse:
			prompt_texture = JoypadSupport.get_mouse_prompt_for(_event_mouse)
		_event_joybutton:
			prompt_texture = JoypadSupport.get_joypad_button_prompt_for(_event_joybutton)
		_event_joybutton:
			print("Change this line once Joy Axis support is implemented")
			assert(false)
		_:
			push_match_event_variables_error()
	
	return prompt_texture


func _set_fallback_label() -> bool:
	var success: = false
	if JoypadSupport.joypad_type == JoypadSupport.JoyPads.NO_JOYPAD:
		if _event_keyboard != "":
			success = _set_fallback_for(_event_keyboard)
		elif _event_mouse != "":
			success = _set_fallback_for(_event_mouse)
	else:
		if _event_joybutton != "":
			success = _set_fallback_for(_event_joybutton)
		elif _event_joyaxis != "":
			success = _set_fallback_for(_event_joyaxis)
		elif _event_keyboard != "":
			success = _set_fallback_for(_event_keyboard)
		elif _event_mouse != "":
			success = _set_fallback_for(_event_mouse)
	
	return success


func _set_fallback_for(string_index: String) -> bool:
	var fallback_string: = _get_fallback_string_for(string_index)
	var success = fallback_string != ""
	
	if success:
		_fallback.text = fallback_string
	
	return success


func _get_fallback_string_for(string_index: String) -> String:
	var index: = int(string_index)
	var fallback_string: = ""
	
	match string_index:
		_event_keyboard:
			fallback_string = _get_keyboard_string(index)
		_event_mouse:
			fallback_string = "Mouse Button %s"%[index]
		_event_joybutton:
			fallback_string = Input.get_joy_button_string(index)
		_event_joybutton:
			fallback_string = "Axis %s"%[index]
		_:
			push_match_event_variables_error()
	
	return fallback_string

func _get_keyboard_string(scancode: int) -> String:
	var string = ""
	match scancode:
		KEY_TAB:
			string = "Tab"
		KEY_BACKTAB:
			string = "Tab"
		_:
			string = OS.get_scancode_string(scancode)
	
	return string


func push_match_event_variables_error() -> void:
	push_error("If you got here it's because the string index doesn't match any " + \
			"of the registered _event_* variables. That may mean the event list for " + \
			"this particular action (%s) is empty, though if that's the case this " + \
			"should have been caught by another exception already and you shouldn't be" + \
			"here. Anyway, I hope this helps in debugging."
	)
	assert(false)


func _push_fallback_failed_error() -> void:
	push_error("Unable to set prompt or fallback text for any of the events in %s: "\
			%[_input_action] + \
			"_event_keyboard: %s | "%[_event_keyboard] + \
			"_event_mouse: %s | "%[_event_mouse] + \
			"_event_joybutton: %s | "%[_event_joybutton] + \
			"_event_joyaxis: %s"%[_event_joyaxis] \
	)
	assert(false)


func _on_JoypadSupport_joypad_connected() -> void:
	_setup(_input_action)


func _on_JoypadSupport_joypad_disconnected() -> void:
	_setup(_input_action)

### ---------------------------------------
