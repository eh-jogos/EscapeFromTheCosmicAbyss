extends AnimatedSprite

func _ready():
	self.play()
	add_to_group("interactive_color")
	colors_changed()
	pass


func colors_changed():
	self_modulate = Global.savedata.colors.waves.body
