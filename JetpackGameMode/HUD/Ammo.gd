extends Control

var animation

func _ready():
	animation = self.get_node("AnimationPlayer")
	pass

func used():
	animation.play("shoot")
	yield(animation, "animation_finished")
	self.queue_free()

func play_intro():
	animation.play("intro")
	self.show()

func reset_anim():
	self.hide()
	animation.assigned_animation = "intro"
	animation.seek(0.0,true)
