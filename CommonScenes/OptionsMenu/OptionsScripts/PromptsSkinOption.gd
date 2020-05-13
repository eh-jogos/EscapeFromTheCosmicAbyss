extends BaseArrowsButton
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
const possible_skins: = {
	"Xbox": JS_JoypadIdentifier.JoyPads.XBOX,
	"Playstation": JS_JoypadIdentifier.JoyPads.PLAYSTATION,
	"Switch": JS_JoypadIdentifier.JoyPads.NINTENDO,
}

const text_string = "Gamepad Skin: %s"

# export variables
# public variables
# private variables
var _current_key: = ""
var _chosen_skin: int = -1
# onready variables
### ---------------------------------------


### Built in Engine Methods ---------------

func _ready():
	_chosen_skin = JoypadSupport.get_chosen_skin()
	_current_key = _translate_chosen_skin()
	text = text_string%[_current_key]


func _on_gui_input(event) -> void:
	if event.is_action_pressed("ui_right"):
		_set_option(1)
	if event.is_action_pressed("ui_left"):
		_set_option(-1)

### ---------------------------------------


### Public Methods ------------------------
### ---------------------------------------


### Private Methods -----------------------
func _set_option(increment: int) -> void:
	_play_change_sfx()
	var possible_keys = possible_skins.keys()
	var current_index = possible_keys.find(_current_key)
	current_index = (current_index + increment) % possible_keys.size()
	
	_current_key = possible_keys[current_index]
	_chosen_skin = possible_skins[_current_key]
	text = text_string%[_current_key]
	
	JoypadSupport.set_chosen_skin(_chosen_skin)


func _translate_chosen_skin() -> String:
	var key: = ""
	match _chosen_skin:
		JS_JoypadIdentifier.JoyPads.UNINDENTIFIED, \
		JS_JoypadIdentifier.JoyPads.XBOX:
			key = "Xbox"
		JS_JoypadIdentifier.JoyPads.PLAYSTATION:
			key = "Playstation"
		JS_JoypadIdentifier.JoyPads.NINTENDO:
			key = "Switch"
		_:
			push_error("Uregistered possible skin: %s | Possible Skins: %s"%[
					_chosen_skin,
					possible_skins.values(),
			])
			assert(false)
	return key


func _on_arrows_highlight_right_pressed() -> void:
	_set_option(1)


func _on_arrows_highlight_left_pressed() -> void:
	_set_option(-1)

### ---------------------------------------


