extends Button

func _ready():
	self.connect("mouse_enter",self,"_on_mouse_enter")
	pass


func _on_mouse_enter():
	self.grab_focus()

