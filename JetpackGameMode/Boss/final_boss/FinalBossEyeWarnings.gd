extends AnimatedSprite2D

@export var warning_level = "warning1" # (String, "warning1", "warning2", "warning3")

func _ready():
	add_to_group("interactive_color")
	colors_changed()


func colors_changed():
	self_modulate = Global.savedata.colors.laser_eye[warning_level]

