extends Camera2D

var camera_offset_x = 0
var target_offset_x = 0
var base_offset = 0

export var path_player: NodePath

var player_position

onready var player = get_node(path_player)
onready var tween = get_node("Tween")
onready var shaker: Shaker = $Shaker

func _ready():
	set_physics_process(true)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	Global.connect("shake_trauma_added", self, "_on_Global_shake_trauma_added")


func _physics_process(_delta):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	player_position = player.get_position()  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	set_position(Vector2(player.get_position().x+camera_offset_x,get_position().y))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review


func set_camera_offset_x(value, seconds, easing = Tween.EASE_IN):
	base_offset = camera_offset_x
	target_offset_x = (abs(base_offset) + value)
	#print("base: %s | target: %s"%[base_offset, target_offset_x])
	tween.interpolate_method(self,"animate_camera_horizontally", 0.01, 1.00, 
			seconds, Tween.TRANS_SINE, easing)
	tween.start()


func animate_camera_horizontally(progress):
	var interpolated_offset = target_offset_x*progress
	camera_offset_x = base_offset + interpolated_offset


func _on_Player_dashing( boolean ):
	#print("Camera.gd | Dashing: %s | Camera Offset: %s"%[boolean, camera_offset_x])
	if boolean:
		set_camera_offset_x(-300,0.2, Tween.EASE_OUT)
	else:
		set_camera_offset_x(0,0.4)


func _on_ObstacleSpawner_setup_laser_eye():
	var laser_eye = get_node("LaserEye")
	laser_eye.start()


func _on_Global_shake_trauma_added(trauma: float) -> void:
	shaker.add_trauma(trauma)
