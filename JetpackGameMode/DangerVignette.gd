extends ColorRect

onready var animator: AnimationPlayer = $AnimationPlayer

var current_duration: = -1

func _ready():
	Global.connect("start_danger", self, "_on_start_danger")


func _on_start_danger(duration: int) -> void:
	if duration > 0:
		animator.play("start")
		current_duration = duration


func _on_ObstacleSpawner_half_beat_spawned():
	if current_duration > 0:
		current_duration -= 1
	elif current_duration == 0:
		animator.play("end")
		current_duration -= 1
