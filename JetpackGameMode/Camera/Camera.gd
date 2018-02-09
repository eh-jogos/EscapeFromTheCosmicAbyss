extends Camera2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
onready var player = get_node("../Player")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	pass

func _fixed_process(delta):
	set_pos(Vector2(player.get_pos().x,get_pos().y))
	pass
