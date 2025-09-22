class_name BasicGameButton
extends BaseButton

@export_enum("Confirm", "Change") var pressed_sfx = "Change"

func _ready():
	self.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	if not self.is_connected("focus_entered", Callable(self, "_on_focus_entered")):
		self.connect("focus_entered", Callable(self, "_on_focus_entered"))


func _on_focus_entered():
	SoundManager.stop_preview_bgm()
	
	if not self.is_connected("focus_exited", Callable(self, "_on_focus_exited")):
		self.connect("focus_exited", Callable(self, "_on_focus_exited"))
	if not self.is_connected("pressed", Callable(self, "_on_pressed")):
		self.connect("pressed", Callable(self, "_on_pressed"))


func _on_mouse_entered():
	if not disabled:
		self.grab_focus()


func _on_focus_exited():
	SoundManager.play_sfx("Select")
	pass


func _on_pressed():
	if self.is_connected("focus_exited", Callable(self, "_on_focus_exited")):
		self.disconnect("focus_exited", Callable(self, "_on_focus_exited"))
	
	if pressed_sfx == "Confirm":
		SoundManager.play_sfx(pressed_sfx)
	else:
		SoundManager.play_sfx(pressed_sfx, true)
		await get_tree().idle_frame
		if not self.is_connected("focus_exited", Callable(self, "_on_focus_exited")):
			self.connect("focus_exited", Callable(self, "_on_focus_exited"))
	
