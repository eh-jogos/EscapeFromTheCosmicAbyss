extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var fullscreen
var arrows_animator

func _ready():
	# Called every time the node is added to the scene.
	if not self.is_connected("mouse_enter",self,"_on_mouse_enter"):
		self.connect("mouse_enter",self,"_on_mouse_enter")
	
	if not self.is_connected("focus_enter",self,"_on_focus_enter"):
		self.connect("focus_enter",self,"_on_focus_enter")
	
	if not self.is_connected("focus_exit",self,"_on_focus_exit"):
		self.connect("focus_exit",self,"_on_focus_exit")
	
	arrows_animator = get_node("ArrowAnimator")

	fullscreen = Global.savedata["options"]["fullscreen"]
	
	if fullscreen:
		self.set_text("Fullscreen: On")
	else:
		self.set_text("Fullscreen: Off")

func _input(event):
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
		change_screen_mode()

func change_screen_mode():
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
	set_process_input(true)
	arrows_animator.play("enabled")

func _on_focus_exit():
	#print("FOCUS LOST")
	set_process_input(false)
	arrows_animator.play("disabled")
