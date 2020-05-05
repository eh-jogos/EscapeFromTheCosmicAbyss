extends Sprite

#internal nodes
var animator

func _ready():
	#instantiating internal nodes
	animator = self.get_node("AnimationPlayer")
	animator.play("base")

func apply_upgrade():
	animator.play("confirmed")

func pending_upgrade():
	animator.play("pending")

func base_slot():
	animator.play("base")

func confirm_upgrade():
	animator.play("confirmed")

