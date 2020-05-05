extends Button

func _ready():
	connect("focus_entered", self, "_on_focus_enter")
	connect("focus_exited", self, "_on_focus_exit")


func _on_focus_enter():
	var animator = get_node("AnimationPlayer")
	animator.play("loop")

func _on_focus_exit():
	var animator = get_node("AnimationPlayer")
	animator.play("base")
