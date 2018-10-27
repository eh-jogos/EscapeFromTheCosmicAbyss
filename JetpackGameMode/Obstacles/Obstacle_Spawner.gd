extends Position2D

export(NodePath) var obstacle_parent
export(NodePath) var obstacle_half_parent
export(PackedScene) var none
export(PackedScene) var pipe
export(PackedScene) var double_pipe
export(PackedScene) var triple_pipe
export(PackedScene) var wall

var obstacles = []

var obstacle_group
var half_group
var half_countdown = 4

func _ready():
	obstacle_group = get_node(obstacle_parent)
	half_group = get_node(obstacle_half_parent)
	obstacles = [
		none,
		pipe,
		double_pipe,
		triple_pipe,
		wall
	]
	
	spawn(1)
	pass

func spawn(obstacle_enum):
	var obstacle = obstacles[obstacle_enum].instance()
	var position = self.get_global_pos()
	obstacle.set_pos(position)
	obstacle_group.add_child(obstacle)

func half_spawn(obstacle_num):
	var obstacle = obstacles[obstacle_num].instance()
	var position = self.get_global_pos()
	obstacle.set_pos(position)
	half_group.add_child(obstacle)

func next_beat():
	spawn(1)

func next_half_beat():
	print("half")
	if half_countdown == 0:
		print("halfcall")
		half_spawn(1)
		half_countdown = 4
	else:
		half_countdown -= 1


func _on_Beat_area_exit( area ):
	if area.is_in_group("score") and not area.get_parent().get_parent() == half_group:
		next_beat()

func _on_HalfBeat_area_exit( area ):
	if area.is_in_group("score") and not area.get_parent().get_parent() == half_group:
		next_half_beat()
