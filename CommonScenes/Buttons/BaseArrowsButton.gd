extends Button
class_name BaseArrowsButton
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# export variables
# public variables
# private variables
# onready variables
onready var arrows_highlight = get_node("ArrowsIndicator")
### ---------------------------------------


### Built in Engine Methods ---------------
func _ready() -> void:
	if not self.is_connected("mouse_entered",self,"_on_mouse_enter"):
		self.connect("mouse_entered",self,"_on_mouse_enter")
	
	if not self.is_connected("focus_entered",self,"_on_focus_enter"):
		self.connect("focus_entered",self,"_on_focus_enter")
	
	if not self.is_connected("focus_exited",self,"_on_focus_exit"):
		self.connect("focus_exited",self,"_on_focus_exit")
	
	if not self.is_connected("gui_input", self, "_on_gui_input"):
		self.connect("gui_input", self, "_on_gui_input")
	
	if not arrows_highlight.is_connected("right_pressed", self, "_on_arrows_highlight_right_pressed"):
		arrows_highlight.connect("right_pressed", self, "_on_arrows_highlight_right_pressed")
	
	if not arrows_highlight.is_connected("left_pressed", self, "_on_arrows_highlight_left_pressed"):
		arrows_highlight.connect("left_pressed", self, "_on_arrows_highlight_left_pressed")


### ---------------------------------------


### Public Methods ------------------------
func change_option() -> void:
	push_error("This method must be overridden in a script that extends this one")
	assert(false)

### ---------------------------------------


### Private Methods -----------------------
func _play_change_sfx() -> void:
	SoundManager.play_sfx("Change", true)


func _on_mouse_enter() -> void:
	self.grab_focus()


func _on_focus_enter() -> void:
	#print("FOCUS GRABBED")
	set_process_input(true)
	arrows_highlight.show_highlight()


func _on_focus_exit() -> void:
	#print("FOCUS LOST")
	set_process_input(false)
	arrows_highlight.stop_highlight()
	SoundManager.play_sfx("Select")


func _on_gui_input(event) -> void:
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
		change_option()


func _on_arrows_highlight_right_pressed() -> void:
	change_option()


func _on_arrows_highlight_left_pressed() -> void:
	change_option()

### ---------------------------------------


