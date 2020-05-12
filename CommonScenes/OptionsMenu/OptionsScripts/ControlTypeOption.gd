extends BaseArrowsButton
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# export variables
# public variables
# private variables
# onready variables
onready var animator = $ControlTypeSelector
### ---------------------------------------


### Built in Engine Methods ---------------

func _ready():
	JoypadSupport.connect("joypad_connected", self, "_on_JoypadSupport_joypad_connected")
	JoypadSupport.connect("joypad_disconnected", self, "_on_JoypadSupport_joypad_disconnected")
	
	if JoypadSupport.joypad_type == JoypadSupport.JoyPads.NO_JOYPAD:
		animator.play("keyboard_menu")
	else:
		animator.play("joypad_menu")

### ---------------------------------------


### Public Methods ------------------------
func change_option() -> void:
	_play_change_sfx()
	var current_animation = animator.assigned_animation
	match current_animation:
		"joypad_menu":
			animator.play("keyboard_menu")
		"keyboard_menu":
			animator.play("joypad_menu")
		_:
			push_error("Undefined animation: %s"%[current_animation])
			assert(false)

### ---------------------------------------


### Private Methods -----------------------
func grab_focus_if_control_menu():
	if get_parent().visible:
		grab_focus()


func _on_JoypadSupport_joypad_connected() -> void:
	animator.play("joypad_menu")


func _on_JoypadSupport_joypad_disconnected() -> void:
	animator.play("keyboard_menu")

### ---------------------------------------


