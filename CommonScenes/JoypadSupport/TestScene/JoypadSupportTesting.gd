extends Control
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# export variables
# public variables
# private variables

# onready variables
@onready var _instruction_label: Label = get_node("Instruction")
@onready var _test_label: Label = get_node("Fallback")
@onready var _test_prompt: TextureRect = get_node("Prompt")

### ---------------------------------------


### Built in Engine Methods ---------------

func _ready():
	if not get_tree().get_root().has_node("/root/JoypadSupport"):
		push_error("Please register the JoypadSupport scene as an autoload on Project Settings " + \
				"with JoypadSupport as name.\nOr change the code below to point to where " + \
				"JoypadSupport is or it's equivalent.1")
		assert(false)
	
	JoypadSupport.connect("joypad_connected", Callable(self, "_on_JoypadSupport_joypad_connected"))
	JoypadSupport.connect("joypad_disconnected", Callable(self, "_on_JoypadSupport_joypad_disconnected"))
	_update_joypad_name()


func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed():
		_handle_keyboard_input(event)
	
	if event is InputEventMouseButton and event.is_pressed():
		_handle_mouse_input(event)
	
	if (
			event is InputEventJoypadButton and event.is_pressed()
			or event is InputEventJoypadMotion and event.is_pressed()
	):
		_handle_joypad_input(event)

### ---------------------------------------


### Public Methods ------------------------
### ---------------------------------------


### Private Methods -----------------------

func _handle_keyboard_input(key_event: InputEventKey) -> void:
	_show_prompt_or_text(JoypadSupport.prompts_keyboard, key_event.keycode)


func _handle_mouse_input(mouse_event: InputEventMouseButton) -> void:
	_show_prompt_or_text(JoypadSupport.prompts_mouse, mouse_event.button_index)


func _handle_joypad_input(pad_event: InputEvent) -> void:
	_show_prompt_or_text_using_gallery(JoypadSupport.gallery_joypad, pad_event)


func _show_prompt_or_text_using_gallery(gallery: PromptGallery, event: InputEvent) -> void:
	_instruction_label.hide()
	_test_prompt.texture = gallery.get_texture_for(event)
	_test_label.text = ""
	if _test_prompt.texture == null:
		_test_label.text = JoypadSupport.get_fallback_string_for(event)


func _show_prompt_or_text(prompts: ResourcePreloader, keycode: int) -> void:
	_instruction_label.hide()
	if prompts.has_resource(str(keycode)):
			_test_prompt.texture = prompts.get_resource(str(keycode))
			_test_label.text = ""
	else:
		_test_prompt.texture = null
		_test_label.text = "%s"%[OS.get_keycode_string(keycode)]


func _update_joypad_name():
	var joypad_name: Label = get_node("JoypadName")
	var joypad_layout: Label = get_node("IdentifiedLayout")
	var device_name: = Input.get_joy_name(0)
	joypad_name.text = device_name
	joypad_layout.text = JS_JoypadIdentifier.JoyPads.keys()[JoypadSupport.get_joypad_type()]


func _on_JoypadSupport_joypad_connected() -> void:
	_update_joypad_name()


func _on_JoypadSupport_joypad_disconnected() -> void:
	_update_joypad_name()

### ---------------------------------------
