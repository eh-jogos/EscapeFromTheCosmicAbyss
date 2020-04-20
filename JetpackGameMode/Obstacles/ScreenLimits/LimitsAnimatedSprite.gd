extends AnimatedSprite

func _ready():
	self.play()
	add_to_group("interactive_color")
	colors_changed()
	pass


func colors_changed():
	set_modulate(Global.savedata.colors.waves.body)