# Write your doc string for this file here
extends CanvasLayer

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

onready var _content_root = $Content
onready var _focus_button = $Content/MenuContainer/Steam
onready var _back_button = $Content/MenuContainer/Back
onready var _prompt = $PromptLegendConfirmCancel

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready():
	_prompt.show()
	_focus_button.grab_focus()


func _unhandled_input(event):
	if event.is_action("ui_cancel"):
		get_viewport().set_input_as_handled()
	
	if event.is_action_released("ui_cancel"):
		if _back_button.has_focus():
			_exit()
		else:
			_back_button.grab_focus()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _exit() -> void:
	if get_tree().get_current_scene() == self:
		_content_root.hide()
		_prompt.hide()
	else:
		ScreenManager.black_transition_from_above()


func _on_Steam_pressed():
	OS.shell_open("https://store.steampowered.com/app/1315250/")


func _on_Itch_pressed():
	OS.shell_open("https://eh-jogos.itch.io/cosmicabyss")


func _on_Back_pressed():
	_exit()

### -----------------------------------------------------------------------------------------------
