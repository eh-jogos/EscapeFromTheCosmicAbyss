tool
extends Particles2D


onready var animator: AnimationPlayer = $AnimationPlayer


func start_charge() -> void:
	animator.play("charge")
	emitting = true
