extends Button

var is_invincible = false
var arrows_animator

func _ready():
	if not self.is_connected("mouse_enter",self,"_on_mouse_enter"):
		self.connect("mouse_enter",self,"_on_mouse_enter")
	
	if not self.is_connected("focus_enter",self,"_on_focus_enter"):
		self.connect("focus_enter",self,"_on_focus_enter")
	
	if not self.is_connected("focus_exit",self,"_on_focus_exit"):
		self.connect("focus_exit",self,"_on_focus_exit")
	
	is_invincible = Global.is_invincible
	
	arrows_animator = get_node("ArrowAnimator")
	_update_text()


func _input(event):
	if event.is_action_pressed("ui_right") or event.is_action_pressed("ui_left"):
		toggle_invincibility()


func toggle_invincibility():
	SoundManager.play_sfx("ui_change", true)

	Global.is_invincible = !Global.is_invincible
	is_invincible = Global.is_invincible
	_update_text()
	Global.emit_signal("update_invincibility")

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
	SoundManager.play_sfx("ui_select")

func _update_text():
	if is_invincible:
		self.set_text("Invincible: On")
	else:
		self.set_text("Invincible: Off")