extends BaseArrowsButton
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# export variables
# public variables
# private variables
var _is_on: = true

# onready variables
onready var animator = get_node("AutodetectSelector")

### ---------------------------------------


### Built in Engine Methods ---------------

func _ready():
	_is_on = JoypadSupport.get_autodetect()
	_change_state_to(_is_on)

### ---------------------------------------


### Public Methods ------------------------
func change_option() -> void:
	_play_change_sfx()
	_is_on = JoypadSupport.get_autodetect()
	_is_on = !_is_on
	JoypadSupport.set_autodetect_to(_is_on)
	_change_state_to(_is_on)

### ---------------------------------------


### Private Methods -----------------------
func _change_state_to(is_on) -> void:
	if is_on:
		animator.play("on")
	else:
		animator.play("off")
### ---------------------------------------


