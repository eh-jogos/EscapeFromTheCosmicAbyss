extends TextureButton

onready var animator = get_node("AnimationPlayer")

func reset() -> void:
	animator.play("base")


func simulate_hover() -> void:
	animator.play("simulate_hover")


func simulate_press() -> void:
	animator.play("simulate_press")
