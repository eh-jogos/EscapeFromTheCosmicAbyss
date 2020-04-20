extends AnimatedSprite


func _ready():
	add_to_group("interactive_color")
	colors_changed()


func colors_changed():
	set_modulate(Global.savedata.colors.final_boss.gengiva)