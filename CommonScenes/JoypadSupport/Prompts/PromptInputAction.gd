extends MarginContainer
# Class to automatize almost everything related to showing Input Prompts. Just Instance the scene
# where you need, set the export variables and it should always show the correct input prompt or a 
# fallback label. Even though it's a tool, it doesn't work well on the editor, better tested on 
# runtime.
#
# Exports:
# - input_action - the name of the action you configured in the ProjectSettings or through code
# - force_type - Default is NONE, and in this state it will prefer to show Joypad Prompts if there
# 				 there is any in this action and if a Joypad is connected, otherwise it will show
# 				 a Keyboard/Mouse prompt. KEYBOARD will force it to only show KEYBOARD/MOUSE prompts
# 				 and JOYPAD will force it to only show JOYPAD prompts. (This is usefull if you want
# 				 to let the user have different profiles for KEYBOARD/JOYPAD so that each menu only
# 				 its relevant Prompts)

### Member Variables and Dependencies -----
# signals 
# enums
enum ForceType {
	NONE,
	KEYBOARD,
	JOYPAD
}
# constants
# export variables
@export var input_action: = "": set = _set_input_action
@export var force_type := ForceType.NONE

# public variables
# private variables
var _event_keyboard: InputEventKey = null
var _event_mouse: InputEventMouseButton = null
var _event_joybutton: InputEventJoypadButton = null
var _event_joyaxis: InputEventJoypadMotion = null

# onready variables
@onready var _prompt: TextureRect = get_node("Prompt")
@onready var _fallback: Label = get_node("Fallback")

### ---------------------------------------


### Built in Engine Methods ---------------

func _ready():
	if input_action == "":
		push_warning("Undefined input_action")
	_setup()
	
	if not get_tree().get_root().has_node("/root/JoypadSupport"):
		push_error("Please register the JoypadSupport scene as an autoload on Project Settings " + \
				"with JoypadSupport as name.Or change the code below to point to where " + \
				"JoypadSupport is or it's equivalent.")
		assert(false)
	
	# Both call backs do the same thing here, but kept them separate to facilitade customization
	# or expansion of each event separately
	JoypadSupport.connect("joypad_connected", Callable(self, "_on_JoypadSupport_joypad_connected"))
	JoypadSupport.connect("joypad_disconnected", Callable(self, "_on_JoypadSupport_joypad_disconnected"))
	JoypadSupport.connect("joypad_manually_changed", Callable(self, "_on_JoypadSupport_joypad_manually_changed"))
	JoypadSupport.connect("input_remapped", Callable(self, "_on_JoypadSupport_input_remapped"))

### ---------------------------------------


### Public Methods ------------------------
### ---------------------------------------


### Private Methods -----------------------
func _set_input_action(value) -> void:
	input_action = value
	if _prompt != null:
		_setup()


func _setup() -> void:
	_reset_event_variables()
	var actions_list: = InputMap.get_actions()
	if actions_list.has(input_action):
		_setup_event_variables()
		_setup_prompt_appearence()
	else:
		if not Engine.is_editor_hint():
			push_warning("Couldn't find %s in input map list: %s"%[input_action, actions_list])
			assert(false)


func _reset_event_variables() -> void:
	_event_keyboard = null
	_event_mouse = null
	_event_joybutton = null
	_event_joyaxis = null


func _setup_event_variables() -> void:
	var event_list: = InputMap.action_get_events(input_action)
	if event_list.size() > 0:
		for event in event_list:
			if event is InputEventKey and _event_keyboard == null:
				_event_keyboard = event
			elif event is InputEventMouseButton and _event_mouse == null:
				_event_mouse = event
			elif event is InputEventJoypadButton and _event_joybutton == null:
				_event_joybutton = event
			elif event is InputEventJoypadMotion and _event_joyaxis == null:
				_event_joyaxis = event
	else:
		if not Engine.is_editor_hint():
			push_error("input map action has no events in it!" + \
					" Register events for it in the Project Settings or through code")
			assert(false)


func _setup_prompt_appearence() -> void:
	_prompt.texture = null
	_fallback.text = ""
	
	var success: = false
	success = _set_prompt_texture()
	
	if not success:
		success = _set_fallback_label()
	
	if not success:
		_push_fallback_failed_error()


func _set_prompt_texture() -> bool:
	var success: = false
	
	if (_has_valid_joypad() and not force_type == ForceType.KEYBOARD):
		if _event_joybutton != null:
			success = _set_prompt_for(_event_joybutton)
		elif _event_joyaxis != null:
			success = _set_prompt_for(_event_joyaxis)
		elif _event_keyboard != null:
			success = _set_prompt_for(_event_keyboard)
		elif _event_mouse != null:
			success = _set_prompt_for(_event_mouse)
	else:
		if _event_keyboard != null:
			success = _set_prompt_for(_event_keyboard)
		elif _event_mouse != null:
			success = _set_prompt_for(_event_mouse)
	
	return success


func _has_valid_joypad() -> bool:
	var value: bool = (
			JoypadSupport.get_joypad_type() != JS_JoypadIdentifier.JoyPads.NO_JOYPAD 
			or force_type == ForceType.JOYPAD
	)
	return value


func _set_prompt_for(event: InputEvent) -> bool:
	var prompt_texture: Texture2D =  _get_prompt_texture_for(event)
	var success = prompt_texture.resource_path != ""
	
	if success:
		_prompt.texture = prompt_texture
	
	return success


func _set_fallback_label() -> bool:
	var success: = false
	
	if _has_valid_joypad() and not force_type == ForceType.KEYBOARD:
		if _event_joybutton != null:
			success = _set_fallback_for(_event_joybutton)
		elif _event_joyaxis != null:
			success = _set_fallback_for(_event_joyaxis)
		elif _event_keyboard != null:
			success = _set_fallback_for(_event_keyboard)
		elif _event_mouse != null:
			success = _set_fallback_for(_event_mouse)
	else:
		if _event_keyboard != null:
			success = _set_fallback_for(_event_keyboard)
		elif _event_mouse != null:
			success = _set_fallback_for(_event_mouse)
	
	return success


func _set_fallback_for(event: InputEvent) -> bool:
	_fallback.text = JoypadSupport.get_fallback_string_for(event)
	var success = _fallback.text != ""
	return success


func _get_prompt_texture_for(event: InputEvent) -> Texture2D:
	var prompt_texture: = CompressedTexture2D.new()
	
	#TODO convert keyboard and mouse prompts to new prompt gallery thingy
	if event is InputEventKey:
		prompt_texture = JoypadSupport.get_keyboard_prompt_for(str(_event_keyboard.keycode))
	elif event is InputEventMouseButton:
		prompt_texture = JoypadSupport.get_mouse_prompt_for(str(_event_mouse.button_index))
	elif event is InputEventJoypadButton:
		prompt_texture = JoypadSupport.get_joypad_button_prompt_for(_event_joybutton)
	elif event is InputEventJoypadMotion:
		prompt_texture = JoypadSupport.get_joypad_button_prompt_for(_event_joyaxis)
	else:
		push_match_event_variables_error()
	
	return prompt_texture


func push_match_event_variables_error() -> void:
	if Engine.is_editor_hint():
		return
	
	push_error("If you got here it's because the string index doesn't match any " + \
			"of the registered _event_* variables. That may mean the event list for " + \
			"this particular action (%s) is empty, though if that's the case "%[input_action] + \
			"this should have been caught by another exception already and you shouldn't be" + \
			"here. Anyway, I hope this helps in debugging."
	)
	assert(false)


func _push_fallback_failed_error() -> void:
	if Engine.is_editor_hint():
		return
	
	push_error("Unable to set prompt or fallback text for any of the events in %s: "\
			%[input_action] + \
			"_event_keyboard: %s | "%[_event_keyboard] + \
			"_event_mouse: %s | "%[_event_mouse] + \
			"_event_joybutton: %s | "%[_event_joybutton] + \
			"_event_joyaxis: %s"%[_event_joyaxis] \
	)
	assert(false)


func _on_JoypadSupport_joypad_connected() -> void:
	_setup()


func _on_JoypadSupport_joypad_disconnected() -> void:
	_setup()


func _on_JoypadSupport_joypad_manually_changed() -> void:
	if (
			force_type != ForceType.KEYBOARD
			or force_type != ForceType.NONE and Input.get_connected_joypads().size() > 0
	):
		_setup()


func _on_JoypadSupport_input_remapped(action_name: String) -> void:
	if input_action == action_name:
		_setup()

### ---------------------------------------
