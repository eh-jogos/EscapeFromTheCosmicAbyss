extends "res://JetpackGameMode/Boss/BackgroundBoss.gd"


func _ready():
	add_to_group("interactive_color")
	colors_changed()


func colors_changed():
	set_modulate(Global.savedata.colors.mid_bg_boss.body)