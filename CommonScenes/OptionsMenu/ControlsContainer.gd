extends VBoxContainer
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# export variables
# public variables
# private variables
# onready variables
### ---------------------------------------


### Built in Engine Methods ---------------

func _ready():
	pass

### ---------------------------------------


### Public Methods ------------------------
### ---------------------------------------


### Private Methods -----------------------
func _on_JoyBoost_pressed():
	JoypadSupport.listen_input_for("boost", JoypadSupport.Modes.JOYPAD)


func _on_JoyDash_pressed():
	JoypadSupport.listen_input_for("dash", JoypadSupport.Modes.JOYPAD)


func _on_JoyShoot_pressed():
	JoypadSupport.listen_input_for("shoot", JoypadSupport.Modes.JOYPAD)


func _on_KeyBoost_pressed():
	JoypadSupport.listen_input_for("boost", JoypadSupport.Modes.KEYBOARD_AND_MOUSE)


func _on_KeyDash_pressed():
	JoypadSupport.listen_input_for("dash", JoypadSupport.Modes.KEYBOARD_AND_MOUSE)


func _on_KeyShoot_pressed():
	JoypadSupport.listen_input_for("shoot", JoypadSupport.Modes.KEYBOARD_AND_MOUSE)


func _on_RestoreJoyDefaults_pressed():
	JoypadSupport.change_profile_to("default_joypad")


func _on_RestoreKeyDefaults_pressed():
	JoypadSupport.change_profile_to("default_keyboard")

### ---------------------------------------
