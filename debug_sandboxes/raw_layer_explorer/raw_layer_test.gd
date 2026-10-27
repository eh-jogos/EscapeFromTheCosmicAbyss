@tool
extends CanvasLayer

var current_level: int = 1

@export var play_laser_eye: bool = false:
	set(value):
		if value:
			_play_laser_eye()
			await get_tree().create_timer(0.5).timeout
			value = false

@export_range(0.0,10.0,0.1,"or_greater") var trauma_test_value: float = 0.8
@export var shake_camera: bool = false:
	set(value):
		if value:
			Global.shake_trauma_added.emit(trauma_test_value)
			await get_tree().create_timer(0.5).timeout
			value = false

@export var shaky_camera_active: bool = false:
	set(value):
		shaky_camera_active = value
		_toggle_cameras(shaky_camera_active)
@export var laser_eye: Node2D

@onready var camera: Camera2D = $WorldVieport/SubViewport/Camera2D
@onready var camera_shaky: Camera2D = $WorldVieport/SubViewport/Camera2D/ShakyCamera

@onready var game_overrides: Array[Node] = [
		$WorldVieport/SubViewport/Obstaculos/Outlines/BottomLimitsOutline0, 
		$WorldVieport/SubViewport/Obstaculos/Outlines/BottomLimitsOutline1, 
		$WorldVieport/SubViewport/Obstaculos/Outlines/TopLimitsOutline0, 
		$WorldVieport/SubViewport/Obstaculos/Outlines/TopLimitsOutline1,
		$WorldVieport/SubViewport/Obstaculos/ScreenLimits/BottomScreenLimits0, 
		$WorldVieport/SubViewport/Obstaculos/ScreenLimits/BottomScreenLimits1, 
		$WorldVieport/SubViewport/Obstaculos/ScreenLimits/TopScreenLimits0, 
		$WorldVieport/SubViewport/Obstaculos/ScreenLimits/TopScreenLimits1,
]

func _ready() -> void:
	laser_eye.game = self
	for node: Node in game_overrides:
		node.game = self


func _play_laser_eye() -> void:
	laser_eye.start()
	pass


func _on_scored(_value:int) -> void:
	print("mock function just to run standalone 'raw layer' tests")
	pass


func _toggle_cameras(is_shaky: bool) -> void:
	if is_shaky:
		camera_shaky.enabled = true
		camera_shaky.make_current()
	else:
		camera_shaky.enabled = false
		camera.make_current()
