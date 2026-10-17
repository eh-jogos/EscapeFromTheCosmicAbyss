extends Control

@onready var animator: AnimationPlayer = $AnimationPlayer

func _ready():
	pass

func use_shield():
	animator.play_backwards("intro")
	await animator.animation_finished
	queue_free()

func play_intro():
	animator.play("intro")
