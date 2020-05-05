extends TextureRect  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review

func _ready():
	add_to_group("interactive_color")
	colors_changed()


func colors_changed():
	self_modulate = Global.savedata.colors.tentacles.outline

