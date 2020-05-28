extends Button

var fullscreen
var arrows_highlight

func _ready():
	set_process_input(false)
	
	if not self.is_connected("mouse_entered",self,"_on_mouse_enter"):
		self.connect("mouse_entered",self,"_on_mouse_enter")
	
	if not self.is_connected("focus_entered",self,"_on_focus_enter"):
		self.connect("focus_entered",self,"_on_focus_enter")
	
	if not self.is_connected("focus_exited",self,"_on_focus_exit"):
		self.connect("focus_exited",self,"_on_focus_exit")
	
	arrows_highlight = get_node("ArrowsIndicator")

	fullscreen = Global.savedata["options"]["fullscreen"]
	
	if fullscreen:
		self.set_text("Fullscreen: On")
	else:
		self.set_text("Fullscreen: Off")
	


func _input(event):
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
		change_screen_mode()


func change_screen_mode():
	SoundManager.play_sfx("Change", true)
	
	if fullscreen:
		OS.set_window_fullscreen(false)
		fullscreen = OS.is_window_fullscreen()
		Global.update_option_fullscreen(fullscreen)
		
		self.set_text("Fullscreen: Off")
		#print("OFF")
	else:
		OS.set_window_fullscreen(true)
		fullscreen = OS.is_window_fullscreen()
		Global.update_option_fullscreen(fullscreen)
		
		self.set_text("Fullscreen: On")
		#print("ON")

func _on_mouse_enter():
	self.grab_focus()

func _on_focus_enter():
	#print("FOCUS GRABBED")
	SoundManager.stop_preview_bgm()
	set_process_input(true)
	arrows_highlight.show_highlight()


func _on_focus_exit():
	#print("FOCUS LOST")
	set_process_input(false)
	arrows_highlight.stop_highlight()
	SoundManager.play_sfx("Select")



func _on_ArrowsIndicator_right_pressed():
	change_screen_mode()


func _on_ArrowsIndicator_left_pressed():
	change_screen_mode()

