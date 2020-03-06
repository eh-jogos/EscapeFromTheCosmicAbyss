extends Button

export(String, "ui_confirm", "ui_change") var pressed_sfx = "ui_change"

func _ready():
	self.connect("mouse_enter",self,"_on_mouse_enter")
	if not self.is_connected("focus_enter", self, "_on_focus_enter"):
		self.connect("focus_enter", self, "_on_focus_enter")


func _on_focus_enter():
	if not self.is_connected("focus_exit", self, "_on_focus_exit"):
		self.connect("focus_exit", self, "_on_focus_exit")
	if not self.is_connected("pressed", self, "_on_pressed"):
		self.connect("pressed", self, "_on_pressed")


func _on_mouse_enter():
	self.grab_focus()


func _on_focus_exit():
	SoundManager.play_sfx("ui_select")


func _on_pressed():
	if self.is_connected("focus_exit", self, "_on_focus_exit"):
		self.disconnect("focus_exit", self, "_on_focus_exit")
	
	if pressed_sfx == "ui_confirm":
		SoundManager.play_sfx_with_reverb(pressed_sfx)
	else:
		SoundManager.play_sfx(pressed_sfx, true)
		yield(get_tree(), "idle_frame")
		if not self.is_connected("focus_exit", self, "_on_focus_exit"):
			self.connect("focus_exit", self, "_on_focus_exit")
	