extends AudioStreamPlayer

func _ready():
	add_to_group("sfx_player")


func adjust_volume_to(value):
	var float_value = value/100.0
	var db_value = (1 - float_value) * -80
	volume_db = db_value
