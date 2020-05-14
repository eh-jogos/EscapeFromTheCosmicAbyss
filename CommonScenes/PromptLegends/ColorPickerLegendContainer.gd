extends HBoxContainer
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# public variables - order: export > normal var > onready 
# private variables - order: export > normal var > onready
onready var _joypad_sv: HBoxContainer = $JoypadSaturationValue
onready var _joypad_hue: HBoxContainer = $JoypadHue
onready var _keyboard_sv: HBoxContainer = $keyboardSaturationValue
onready var _keyboard_hue: HBoxContainer = $KeyboardHue

### ---------------------------------------


### Built in Engine Methods ---------------
func _ready():
	JoypadSupport.connect("joypad_connected", self, "_onJoypadSupport_joypad_connected")
	JoypadSupport.connect("joypad_disconnected", self, "_onJoypadSupport_joypad_disconnected")
	
	if JoypadSupport.get_joypad_type() == JS_JoypadIdentifier.JoyPads.NO_JOYPAD:
		_onJoypadSupport_joypad_disconnected()
	else:
		_onJoypadSupport_joypad_connected()

### ---------------------------------------


### Public Methods ------------------------
### ---------------------------------------


### Private Methods -----------------------
func _onJoypadSupport_joypad_connected() -> void:
	_joypad_sv.show()
	_joypad_hue.show()
	_keyboard_sv.hide()
	_keyboard_hue.hide()
	
	_update_stick_textures()


func _onJoypadSupport_joypad_disconnected() -> void:
	_joypad_sv.hide()
	_joypad_hue.hide()
	_keyboard_sv.show()
	_keyboard_hue.show()


func _update_stick_textures() -> void:
	var stick_texture_rects = [$JoypadSaturationValue/LeftStickTexture, $JoypadHue/RightStickTexture]
	for texture_rect in stick_texture_rects:
		var stick_texture = texture_rect.get_node("ResourcePreloader").get_resource(
				str(JoypadSupport.get_joypad_type())
				)
		texture_rect.texture = stick_texture
### ---------------------------------------


