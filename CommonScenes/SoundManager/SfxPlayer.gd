extends SamplePlayer

func _ready():
	add_to_group("sfx_player")


func adjust_volume_to(value):
	var float_value = value/100.0
	set_default_volume(float_value)