extends AnimatedSprite

export(String, "warning1", "warning2", "warning3") var warning_level = "warning1"

func _ready():
	add_to_group("interactive_color")
	colors_changed()


func colors_changed():
	set_modulate(Global.savedata.colors.laser_eye[warning_level])