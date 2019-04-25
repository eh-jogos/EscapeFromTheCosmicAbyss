extends Button

func _ready():
	self.connect("mouse_enter",self,"_on_mouse_enter")

func _on_mouse_enter():
	self.grab_focus()
