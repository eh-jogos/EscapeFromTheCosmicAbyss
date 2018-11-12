extends ViewportSprite

var tentacle_top
var tentacle_bottom
var base_position

func _ready():
	tentacle_top = get_node("Viewport/TentacleTop")
	tentacle_bottom = get_node("Viewport/TentacleBottom")
	base_position = self.get_pos()
	
	toggle_tentacle_visibility(true)
	
	tentacle_top.set_pos(base_position + tentacle_top.get_pos())

func toggle_tentacle_visibility(on_off):
	if on_off:
		tentacle_top.show()
		tentacle_bottom.show()
	else:
		tentacle_top.hide()
		tentacle_bottom.hide()