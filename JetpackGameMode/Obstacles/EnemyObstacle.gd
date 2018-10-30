extends StaticBody2D

var pipe_brain

signal die

func _ready():
	pipe_brain = self.get_node("../../../PipeBrain")
	pass

func kill_player(offset):
	var offset_y = offset.y
	pipe_brain._on_kill_player(self, offset_y)

func die():
	emit_signal("die")
