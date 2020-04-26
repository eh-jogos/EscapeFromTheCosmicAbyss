extends TextureButton

func simulate_press():
	var animator = get_node("AnimationPlayer")
	animator.play("simulate_press")
