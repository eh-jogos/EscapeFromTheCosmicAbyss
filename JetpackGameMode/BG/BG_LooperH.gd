extends AnimatedSprite2D

var end_point

func _ready():
	end_point = get_node("EndPoint")
	set_process(true)


func _process(_delta):
	#print("Global Pos: %s | Pos: %s"%[global_position, position])
	if end_point.global_position.x < 0:
		#print("Move Sprite!")
		frame = randi() % 5
		var new_pos = Vector2(position.x + (2*2020), position.y)
		position = new_pos
