extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var fullscreen
var arrows_animator

func _ready():
	# Called every time the node is added to the scene.
	self.connect("mouse_enter",self,"_on_mouse_enter")
	
	set_process_input(true)
	
	arrows_animator = get_node("ArrowAnimator")
	arrows_animator.play("enabled")
	
	fullscreen = Global.savedata["fullscreen"]
	
	if fullscreen:
		self.set_text("Fullscreen: On")
	else:
		self.set_text("Fullscreen: Off")
	
	
	pass


func _input(event):
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
		change_screen_mode()

func change_screen_mode():
	if fullscreen:
		OS.set_window_fullscreen(false)
		fullscreen = OS.is_window_fullscreen()
		Global.update_fullscreen(fullscreen)
		
		self.set_text("Fullscreen: Off")
		#print("OFF")
	else:
		OS.set_window_fullscreen(true)
		fullscreen = OS.is_window_fullscreen()
		Global.update_fullscreen(fullscreen)
		
		self.set_text("Fullscreen: On")
		#print("ON")

func _on_mouse_enter():
	self.grab_focus()
