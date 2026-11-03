extends Button

var is_invincible = false
var arrows_highlight

func _ready():
	set_process_input(false)
	
	if not is_connected("mouse_entered", Callable(self, "_on_mouse_enter")):
		connect("mouse_entered", Callable(self, "_on_mouse_enter"))
	
	if not is_connected("focus_entered", Callable(self, "_on_focus_enter")):
		connect("focus_entered", Callable(self, "_on_focus_enter"))
	
	if not is_connected("focus_exited", Callable(self, "_on_focus_exit")):
		connect("focus_exited", Callable(self, "_on_focus_exit"))
	
	is_invincible = Global.is_invincible
	
	arrows_highlight = get_node("ArrowsIndicator")
	_update_text()
	


func _input(event):
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
		toggle_invincibility()


func toggle_invincibility():
	SoundManager.play_sfx("Change", true)

	Global.is_invincible = !Global.is_invincible
	is_invincible = Global.is_invincible
	_update_text()
	Global.update_invincibility.emit()

func _on_mouse_enter():
	grab_focus()

func _on_focus_enter():
	#print("FOCUS GRABBED")
	set_process_input(true)
	arrows_highlight.show_highlight()


func _on_focus_exit():
	#print("FOCUS LOST")
	set_process_input(false)
	arrows_highlight.stop_highlight()
	SoundManager.play_sfx("Select")

func _update_text():
	if is_invincible:
		set_text("Invincible: On")
	else:
		set_text("Invincible: Off")

func _on_ArrowsIndicator_right_pressed():
	toggle_invincibility()


func _on_ArrowsIndicator_left_pressed():
	toggle_invincibility()
