extends ColorRect

func _ready():
	add_to_group("interactive_color")
	colors_changed()


func colors_changed():
	color = Global.savedata.colors.laser_eye.laser_outline
