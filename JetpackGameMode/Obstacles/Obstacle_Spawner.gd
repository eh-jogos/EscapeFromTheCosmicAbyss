extends Marker2D

signal setup_laser_eye
signal level_ready
signal level_end
signal update_visualization
signal beat_spawned
signal half_beat_spawned

@export var path_camera: NodePath
@export var obstacle_parent: NodePath
@export var obstacle_half_parent: NodePath
@export var none: PackedScene
@export var pipe: PackedScene
@export var double_tentacle: PackedScene
@export var triple_tentacle: PackedScene
@export var wall_tentacle: PackedScene
@export var laser_eye: PackedScene
@export var shield_up: PackedScene
@export var ammo_up: PackedScene


var camera
var obstacle_group
var half_group
var level: Level
var half_countdown = 4

var obstacles: Dictionary = {}

func _ready():
	camera = get_node(path_camera)
	obstacle_group = get_node(obstacle_parent)
	half_group = get_node(obstacle_half_parent)
	obstacles = {
		LevelData.ObstacleTypes.NONE: none,
		LevelData.ObstacleTypes.TENTACLE: pipe,
		LevelData.ObstacleTypes.DOUBLE_TENTACLE: double_tentacle,
		LevelData.ObstacleTypes.TRIPLE_TENTACLE: triple_tentacle,
		LevelData.ObstacleTypes.WALL_TENTACLE: wall_tentacle,
		LevelData.ObstacleTypes.LASER_EYE: laser_eye,
		LevelData.ObstacleTypes.SHIELD_UP: shield_up,
		LevelData.ObstacleTypes.AMMO_UP: ammo_up
	}

func _physics_process(_delta):
	global_position.x = camera.global_position.x + 960


func spawn(obstacle_num: int):
	var obstacle = obstacles[obstacle_num].instantiate()
	var position = get_global_position()
	obstacle.set_position(position)
	obstacle_group.call_deferred("add_child", obstacle)
	
	if obstacle_num == LevelData.ObstacleTypes.LASER_EYE:
		setup_laser_eye.emit()


func half_spawn(obstacle_num: int):
	var obstacle = obstacles[obstacle_num].instantiate()
	var position = get_global_position()
	obstacle.set_position(position)
	half_group.call_deferred("add_child", obstacle)
	
	if obstacle_num == LevelData.ObstacleTypes.LASER_EYE:
		setup_laser_eye.emit()


func next_beat():
	if level["beats"].size() > 0:
		spawn(level["beats"][0])
		level["beats"].pop_front()
		beat_spawned.emit()
		#print(level)
	else:
		level_end.emit()


func next_half_beat():
	if level["half_beats"].size() > 0:
		half_spawn(level["half_beats"][0])
		level["half_beats"].pop_front()
		half_beat_spawned.emit()
		#print(level)


func set_level(p_level: Level) -> void:
	level = p_level
	print("Obstacle_Spawner.gd | Level: %s"%[level])
	
	level_ready.emit(level)
	next_beat()

func _on_Beat_area_exit( area ):
	if area.is_in_group("score") and not area.get_parent().get_parent() == half_group:
		next_beat()
		update_visualization.emit()

func _on_HalfBeat_area_exit( area ):
	if area.is_in_group("score") and not area.get_parent().get_parent() == half_group:
		next_half_beat()
		update_visualization.emit()

func connect_tutorial_signal(object):
	if not is_connected("update_visualization", Callable(object, "beat_countdown")):
		connect("update_visualization", Callable(object, "beat_countdown"))
