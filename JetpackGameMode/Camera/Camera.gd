extends Camera2D

var camera_offset_x = 0
var target_offset_x = 0
var base_offset = 0

var player_position

onready var player = get_node("../Player")
onready var tween = get_node("Tween")
onready var obstacle_spawner = get_node("ObstacleSpawner")

func _ready():
	set_fixed_process(true)
	if not obstacle_spawner.is_connected("setup_laser_eye", self, "_on_setup_laser_eye"):
		obstacle_spawner.connect("setup_laser_eye", self, "_on_setup_laser_eye")


func _fixed_process(delta):
	player_position = player.get_pos()
	set_pos(Vector2(player.get_pos().x+camera_offset_x,get_pos().y))


func set_camera_offset_x(value, seconds):
	base_offset = camera_offset_x
	target_offset_x = value
	tween.interpolate_method(self,"animate_camera_horizontally", 0.01, 1.00, 
			seconds, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()


func animate_camera_horizontally(progress):
	var interpolated_offset = target_offset_x*progress
	camera_offset_x = base_offset + interpolated_offset


func _on_setup_laser_eye(marker):
	var laser_eye = get_node("LaserEye")
	laser_eye.start()
