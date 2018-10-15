extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	self.connect("mouse_enter",self,"_on_mouse_enter")
	pass


func _on_mouse_enter():
	self.grab_focus()
	pass # replace with function body
