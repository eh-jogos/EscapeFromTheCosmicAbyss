extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var track_volume
var arrows_animator

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	if not self.is_connected("mouse_enter",self,"_on_mouse_enter"):
		self.connect("mouse_enter",self,"_on_mouse_enter")
	
	if not self.is_connected("focus_enter",self,"_on_focus_enter"):
		self.connect("focus_enter",self,"_on_focus_enter")
	
	if not self.is_connected("focus_exit",self,"_on_focus_exit"):
		self.connect("focus_exit",self,"_on_focus_exit")
	
	arrows_animator = get_node("ArrowAnimator")
	
	track_volume = Global.savedata["options"]["bgm volume"]
	self.set_text("BGM Volume: "+str(track_volume))

func _input(event):
	if event.is_action_pressed("ui_right"):
		change_bgm_volume(true)
	elif event.is_action_pressed("ui_left"):
		change_bgm_volume(false)

func change_bgm_volume(direction):
	var go_up = direction
	
	SoundManager.play_sfx("ui_change", true)
	
	if go_up:
		if track_volume < 100:
			track_volume += 10
	else:
		if track_volume > 0:
			track_volume -= 10
	
	self.set_text("BGM Volume: "+str(track_volume))
	
	SoundManager.change_bgm_volume(track_volume)
	Global.update_option_bgmvolume(track_volume)

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
