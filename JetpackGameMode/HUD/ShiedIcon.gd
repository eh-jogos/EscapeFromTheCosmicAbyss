extends Control

var animation

func _ready():
	animation = self.get_node("AnimationPlayer")
	pass

func use_shield():
	animation.play_backwards("intro")
	await animation.animation_finished
	self.queue_free()

func play_intro():
	animation.play("intro")
